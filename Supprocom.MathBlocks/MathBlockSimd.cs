using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

// Block loops over double spans. Every operation here gives, element for element, exactly the double the scalar
// function gives. IEEE 754 addition, subtraction, multiplication and division are correctly rounded per element
// whether done in a vector register or a scalar one, and the JIT does not contract a vector multiply and add into a
// fused multiply-add, so a packed result has the same bits as the scalar result (a NaN result is the same default
// NaN). Minimum and maximum are not the hardware instructions: they reproduce MathBlockPrimitives.Min and Max for
// operands that are not NaN, see the callers' precondition.
internal static class MathBlockSimd
{
    // Four doubles per 256-bit block. Callers use blocks only where Vector256 is hardware accelerated.
    internal const int BlockWidth = 4;

    private const ulong ExponentMask = 0x7ff0_0000_0000_0000ul;

    // True when every element is finite. An element is finite exactly when its exponent bits are not all ones,
    // which is MathBlockPrimitives.IsFinite. The vector loop tests whole blocks and the tail is tested one by one.
    internal static bool UseBlocks => Vector256.IsHardwareAccelerated;

    internal static bool AllFinite(ReadOnlySpan<float> values)
    {
        var index = 0;
        if (UseBlocks && values.Length >= BlockWidth)
        {
            var mask = Vector256.Create(ExponentMask);
            for (; UseBlocks && index <= values.Length - BlockWidth; index += BlockWidth)
            {
                var bits = Vector256.AsUInt64(Vector256.Create<float>(values[index..]));
                if (Vector256.EqualsAny(bits & mask, mask))
                    return false;
            }
        }
        for (; index < values.Length; index++)
            if (!Math.IsFinite(values[index]))
                return false;
        return true;
    }

    // True when no element of the block starting at the offset is infinite or NaN. The block holds a full vector.
    internal static bool BlockIsFinite(Vector256<float> block)
    {
        var mask = Vector256.Create(ExponentMask);
        return !Vector256.EqualsAny(Vector256.AsUInt64(block) & mask, mask);
    }

    // Minimum for operands that are not NaN. Unequal operands give the smaller. Equal operands give the same bits
    // unless both are zero, where the result is -0 if either is -0: the bitwise OR of the two, as Min returns.
    internal static Vector256<float> MinimumWithoutNaN(Vector256<float> left, Vector256<float> right)
    {
        var tie = Vector256.AsDouble(Vector256.AsUInt64(left) | Vector256.AsUInt64(right));
        return Vector256.ConditionalSelect(
            Vector256.LessThan(left, right),
            left,
            Vector256.ConditionalSelect(Vector256.GreaterThan(left, right), right, tie));
    }

    // Maximum for operands that are not NaN: the bitwise AND of equal operands is +0 unless both are -0, as Max returns.
    internal static Vector256<float> MaximumWithoutNaN(Vector256<float> left, Vector256<float> right)
    {
        var tie = Vector256.AsDouble(Vector256.AsUInt64(left) & Vector256.AsUInt64(right));
        return Vector256.ConditionalSelect(
            Vector256.GreaterThan(left, right),
            left,
            Vector256.ConditionalSelect(Vector256.LessThan(left, right), right, tie));
    }

    internal static void Add(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<float>(left[index..]) + Vector256.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] + right[index];
    }

    internal static void Subtract(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<float>(left[index..]) - Vector256.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] - right[index];
    }

    internal static void Multiply(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<float>(left[index..]) * Vector256.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] * right[index];
    }

    internal static void Divide(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<float>(left[index..]) / Vector256.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] / right[index];
    }

    // value * scalar per element, in that operand order.
    internal static void Scale(ReadOnlySpan<float> values, float scalar, Span<float> result)
    {
        var index = 0;
        var multiplier = Vector256.Create(scalar);
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<float>(values[index..]) * multiplier).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = values[index] * scalar;
    }

    // The scaled domain: a double x with |x| below TinyLimit is held as x * 2^1074, which is an integer count of the smallest subnormal (2^-1074). Scaling by a power of two commutes with
    // a correctly rounded addition or subtraction as long as nothing overflows, and a sum that lands in the subnormal range is exact in both domains, so a sum or difference done on
    // scaled operands and scaled back gives, bit for bit, the double the unscaled operation gives. In the scaled domain no operand and no result is subnormal (every nonzero value is at
    // least 1), so the hardware never takes its microcode assist for a subnormal operand or result, which costs more than a hundred cycles per operation on x86. The scaling is done on
    // the bit pattern (an integer-to-double conversion for a subnormal, an exponent increment for a normal value), never with a multiplication that would itself be subnormal.
    // Shared by every operation that adds or subtracts doubles of an unknown range; the first user is the prefix difference (MathBlockVectorMath.PrefixDifferenceCompute).
    internal static readonly float TinyLimit = BitConverter.Int32BitsToSingle((long)(1023 - 900) << 52);

    private const ulong SignBit = 0x8000_0000_0000_0000ul;
    private const ulong ExponentOne = 1ul << 52;
    private const ulong ScaleExponent = 1074ul << 52;
    private const ulong TwoToThe52Bits = 0x4330_0000_0000_0000ul;
    private const ulong MantissaMask = 0x000F_FFFF_FFFF_FFFFul;
    private const float TwoToThe52 = 4503599627370496f;

    // True when every element has a magnitude below TinyLimit (a NaN is not below it).
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static bool AllTiny(ReadOnlySpan<float> values)
    {
        var index = 0;
        var limit = TinyLimit;
        if (UseBlocks && values.Length >= BlockWidth)
        {
            var below = Vector256<float>.AllBitsSet;
            var bound = Vector256.Create(limit);
            ref var start = ref System.Runtime.InteropServices.MemoryMarshal.GetReference(values);
            for (; index <= values.Length - BlockWidth; index += BlockWidth)
                below &= Vector256.LessThan(Vector256.Abs(Vector256.LoadUnsafe(ref start, (nuint)index)), bound);
            if (below.ExtractMostSignificantBits() != 0b1111u)
                return false;
        }

        for (; index < values.Length; index++)
            if (!(Math.Abs(values[index]) < limit))
                return false;
        return true;
    }

    // x * 2^1074 for |x| < TinyLimit, exactly, with the sign of x (including the sign of a zero).
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static float ScaleUp(float value)
    {
        var bits = (ulong)BitConverter.SingleToInt32Bits(value);
        var sign = bits & SignBit;
        var magnitude = bits ^ sign;
        var scaled = magnitude < ExponentOne
            ? (float)(long)magnitude
            : BitConverter.UInt32BitsToSingle(magnitude + ScaleExponent);
        return BitConverter.UInt32BitsToSingle(BitConverter.SingleToUInt32Bits(scaled) | sign);
    }

    // The four lanes of ScaleUp, without a branch: a subnormal lane is 2^52 + m (the bit pattern) less 2^52, which is m exactly.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static Vector256<float> ScaleUp(Vector256<float> value)
    {
        var bits = value.AsUInt64();
        var sign = bits & Vector256.Create(SignBit);
        var magnitude = bits ^ sign;
        var subnormal = Vector256.LessThan(magnitude.AsInt64(), Vector256.Create((long)ExponentOne)).AsDouble();
        var fromSubnormal = (magnitude | Vector256.Create(TwoToThe52Bits)).AsDouble() - Vector256.Create(TwoToThe52);
        var fromNormal = (magnitude + Vector256.Create(ScaleExponent)).AsDouble();
        return (Vector256.ConditionalSelect(subnormal, fromSubnormal, fromNormal).AsUInt64() | sign).AsDouble();
    }

    // value * 2^-1074 for a value that is a finite scaled count (an integer below 2^52 gives a subnormal or zero, anything larger a normal double).
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static float ScaleDown(float value)
    {
        var bits = (ulong)BitConverter.SingleToInt32Bits(value);
        var sign = bits & SignBit;
        var magnitude = BitConverter.UInt32BitsToSingle(bits ^ sign);
        var scaled = magnitude < TwoToThe52
            ? (ulong)(long)magnitude
            : BitConverter.SingleToUInt32Bits(magnitude) - ScaleExponent;
        return BitConverter.UInt32BitsToSingle(scaled | sign);
    }

    // The four lanes of ScaleDown: for a lane below 2^52 the low 52 bits of (magnitude + 2^52) hold the integer.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static Vector256<float> ScaleDown(Vector256<float> value)
    {
        var bits = value.AsUInt64();
        var sign = bits & Vector256.Create(SignBit);
        var magnitude = (bits ^ sign).AsDouble();
        var large = Vector256.GreaterThanOrEqual(magnitude, Vector256.Create(TwoToThe52)).AsUInt64();
        var fromInteger = (magnitude + Vector256.Create(TwoToThe52)).AsUInt64() & Vector256.Create(MantissaMask);
        var fromLarge = magnitude.AsUInt64() - Vector256.Create(ScaleExponent);
        return (Vector256.ConditionalSelect(large, fromLarge, fromInteger) | sign).AsDouble();
    }
}
