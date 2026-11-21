using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

// Block loops over single-precision spans. Every operation here gives, element for element, exactly the value the scalar
// function gives. IEEE 754 addition, subtraction, multiplication and division are correctly rounded per element
// whether done in a vector register or a scalar one, and the JIT does not contract a vector multiply and add into a
// fused multiply-add, so a packed result has the same bits as the scalar result (a NaN result is the same default
// NaN). Minimum and maximum are not the hardware instructions: they reproduce MathBlockPrimitives.Min and Max for
// operands that are not NaN, see the callers' precondition.
internal static class MathBlockSimd
{
    // Four singles per 128-bit block. Callers use blocks only where Vector128 is hardware accelerated.
    internal const int BlockWidth = 4;

    private const uint ExponentMask = 0x7f80_0000u;

    // True when every element is finite. An element is finite exactly when its exponent bits are not all ones,
    // which is MathBlockPrimitives.IsFinite. The vector loop tests whole blocks and the tail is tested one by one.
    internal static bool UseBlocks => Vector128.IsHardwareAccelerated;

    internal static bool AllFinite(ReadOnlySpan<float> values)
    {
        var index = 0;
        if (UseBlocks && values.Length >= BlockWidth)
        {
            var mask = Vector128.Create(ExponentMask);
            for (; UseBlocks && index <= values.Length - BlockWidth; index += BlockWidth)
            {
                var bits = Vector128.AsUInt32(Vector128.Create<float>(values[index..]));
                if (Vector128.EqualsAny(bits & mask, mask))
                    return false;
            }
        }
        for (; index < values.Length; index++)
            if (!Math.IsFinite(values[index]))
                return false;
        return true;
    }

    // True when no element of the block starting at the offset is infinite or NaN. The block holds a full vector.
    internal static bool BlockIsFinite(Vector128<float> block)
    {
        var mask = Vector128.Create(ExponentMask);
        return !Vector128.EqualsAny(Vector128.AsUInt32(block) & mask, mask);
    }

    // Minimum for operands that are not NaN. Unequal operands give the smaller. Equal operands give the same bits
    // unless both are zero, where the result is -0 if either is -0: the bitwise OR of the two, as Min returns.
    internal static Vector128<float> MinimumWithoutNaN(Vector128<float> left, Vector128<float> right)
    {
        var tie = Vector128.AsSingle(Vector128.AsUInt32(left) | Vector128.AsUInt32(right));
        return Vector128.ConditionalSelect(
            Vector128.LessThan(left, right),
            left,
            Vector128.ConditionalSelect(Vector128.GreaterThan(left, right), right, tie));
    }

    // Maximum for operands that are not NaN: the bitwise AND of equal operands is +0 unless both are -0, as Max returns.
    internal static Vector128<float> MaximumWithoutNaN(Vector128<float> left, Vector128<float> right)
    {
        var tie = Vector128.AsSingle(Vector128.AsUInt32(left) & Vector128.AsUInt32(right));
        return Vector128.ConditionalSelect(
            Vector128.GreaterThan(left, right),
            left,
            Vector128.ConditionalSelect(Vector128.LessThan(left, right), right, tie));
    }

    internal static void Add(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector128.Create<float>(left[index..]) + Vector128.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] + right[index];
    }

    internal static void Subtract(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector128.Create<float>(left[index..]) - Vector128.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] - right[index];
    }

    internal static void Multiply(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector128.Create<float>(left[index..]) * Vector128.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] * right[index];
    }

    internal static void Divide(ReadOnlySpan<float> left, ReadOnlySpan<float> right, Span<float> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector128.Create<float>(left[index..]) / Vector128.Create<float>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] / right[index];
    }

    // value * scalar per element, in that operand order.
    internal static void Scale(ReadOnlySpan<float> values, float scalar, Span<float> result)
    {
        var index = 0;
        var multiplier = Vector128.Create(scalar);
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector128.Create<float>(values[index..]) * multiplier).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = values[index] * scalar;
    }

    // The scaled domain: a value x with |x| below TinyLimit is held as x * 2^149, which is an integer count of the smallest subnormal (2^-149). Scaling by a power of two commutes with
    // a correctly rounded addition or subtraction as long as nothing overflows, and a sum that lands in the subnormal range is exact in both domains, so a sum or difference done on
    // scaled operands and scaled back gives, bit for bit, the value the unscaled operation gives. In the scaled domain no operand and no result is subnormal (every nonzero value is at
    // least 1), so the hardware never takes its microcode assist for a subnormal operand or result, which costs more than a hundred cycles per operation on x86. The scaling is done on
    // the bit pattern (an integer-to-single conversion for a subnormal, an exponent increment for a normal value), never with a multiplication that would itself be subnormal.
    // Shared by every operation that adds or subtracts values of an unknown range; the first user is the prefix difference (MathBlockVectorMath.PrefixDifferenceCompute).
    internal static readonly float TinyLimit = BitConverter.Int32BitsToSingle((127 - 100) << 23);

    private const uint SignBit = 0x8000_0000u;
    private const uint ExponentOne = 1u << 23;
    private const uint ScaleExponent = 149u << 23;
    private const uint TwoToThe23Bits = 0x4b00_0000u;
    private const uint MantissaMask = 0x007F_FFFFu;
    private const float TwoToThe23 = 8388608f;

    // True when every element has a magnitude below TinyLimit (a NaN is not below it).
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static bool AllTiny(ReadOnlySpan<float> values)
    {
        var index = 0;
        var limit = TinyLimit;
        if (UseBlocks && values.Length >= BlockWidth)
        {
            var below = Vector128<float>.AllBitsSet;
            var bound = Vector128.Create(limit);
            ref var start = ref System.Runtime.InteropServices.MemoryMarshal.GetReference(values);
            for (; index <= values.Length - BlockWidth; index += BlockWidth)
                below &= Vector128.LessThan(Vector128.Abs(Vector128.LoadUnsafe(ref start, (nuint)index)), bound);
            if (below.ExtractMostSignificantBits() != 0b1111u)
                return false;
        }

        for (; index < values.Length; index++)
            if (!(Math.Abs(values[index]) < limit))
                return false;
        return true;
    }

    // x * 2^149 for |x| < TinyLimit, exactly, with the sign of x (including the sign of a zero).
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static float ScaleUp(float value)
    {
        var bits = BitConverter.SingleToUInt32Bits(value);
        var sign = bits & SignBit;
        var magnitude = bits ^ sign;
        var scaled = magnitude < ExponentOne
            ? (float)(int)magnitude
            : BitConverter.UInt32BitsToSingle(magnitude + ScaleExponent);
        return BitConverter.UInt32BitsToSingle(BitConverter.SingleToUInt32Bits(scaled) | sign);
    }

    // The four lanes of ScaleUp, without a branch: a subnormal lane is 2^23 + m (the bit pattern) less 2^23, which is m exactly.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static Vector128<float> ScaleUp(Vector128<float> value)
    {
        var bits = value.AsUInt32();
        var sign = bits & Vector128.Create(SignBit);
        var magnitude = bits ^ sign;
        var subnormal = Vector128.LessThan(magnitude.AsInt32(), Vector128.Create((int)ExponentOne)).AsSingle();
        var fromSubnormal = (magnitude | Vector128.Create(TwoToThe23Bits)).AsSingle() - Vector128.Create(TwoToThe23);
        var fromNormal = (magnitude + Vector128.Create(ScaleExponent)).AsSingle();
        return (Vector128.ConditionalSelect(subnormal, fromSubnormal, fromNormal).AsUInt32() | sign).AsSingle();
    }

    // value * 2^-149 for a value that is a finite scaled count (an integer below 2^23 gives a subnormal or zero, anything larger a normal value).
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static float ScaleDown(float value)
    {
        var bits = BitConverter.SingleToUInt32Bits(value);
        var sign = bits & SignBit;
        var magnitude = BitConverter.UInt32BitsToSingle(bits ^ sign);
        var scaled = magnitude < TwoToThe23
            ? (uint)(int)magnitude
            : BitConverter.SingleToUInt32Bits(magnitude) - ScaleExponent;
        return BitConverter.UInt32BitsToSingle(scaled | sign);
    }

    // The four lanes of ScaleDown: for a lane below 2^23 the low 23 bits of (magnitude + 2^23) hold the integer.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static Vector128<float> ScaleDown(Vector128<float> value)
    {
        var bits = value.AsUInt32();
        var sign = bits & Vector128.Create(SignBit);
        var magnitude = (bits ^ sign).AsSingle();
        var large = Vector128.GreaterThanOrEqual(magnitude, Vector128.Create(TwoToThe23)).AsUInt32();
        var fromInteger = (magnitude + Vector128.Create(TwoToThe23)).AsUInt32() & Vector128.Create(MantissaMask);
        var fromLarge = magnitude.AsUInt32() - Vector128.Create(ScaleExponent);
        return (Vector128.ConditionalSelect(large, fromLarge, fromInteger) | sign).AsSingle();
    }
}
