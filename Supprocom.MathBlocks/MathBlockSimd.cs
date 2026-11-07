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

    internal static bool AllFinite(ReadOnlySpan<double> values)
    {
        var index = 0;
        if (UseBlocks && values.Length >= BlockWidth)
        {
            var mask = Vector256.Create(ExponentMask);
            for (; UseBlocks && index <= values.Length - BlockWidth; index += BlockWidth)
            {
                var bits = Vector256.AsUInt64(Vector256.Create<double>(values[index..]));
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
    internal static bool BlockIsFinite(Vector256<double> block)
    {
        var mask = Vector256.Create(ExponentMask);
        return !Vector256.EqualsAny(Vector256.AsUInt64(block) & mask, mask);
    }

    // Minimum for operands that are not NaN. Unequal operands give the smaller. Equal operands give the same bits
    // unless both are zero, where the result is -0 if either is -0: the bitwise OR of the two, as Min returns.
    internal static Vector256<double> MinimumWithoutNaN(Vector256<double> left, Vector256<double> right)
    {
        var tie = Vector256.AsDouble(Vector256.AsUInt64(left) | Vector256.AsUInt64(right));
        return Vector256.ConditionalSelect(
            Vector256.LessThan(left, right),
            left,
            Vector256.ConditionalSelect(Vector256.GreaterThan(left, right), right, tie));
    }

    // Maximum for operands that are not NaN: the bitwise AND of equal operands is +0 unless both are -0, as Max returns.
    internal static Vector256<double> MaximumWithoutNaN(Vector256<double> left, Vector256<double> right)
    {
        var tie = Vector256.AsDouble(Vector256.AsUInt64(left) & Vector256.AsUInt64(right));
        return Vector256.ConditionalSelect(
            Vector256.GreaterThan(left, right),
            left,
            Vector256.ConditionalSelect(Vector256.LessThan(left, right), right, tie));
    }

    internal static void Add(ReadOnlySpan<double> left, ReadOnlySpan<double> right, Span<double> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<double>(left[index..]) + Vector256.Create<double>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] + right[index];
    }

    internal static void Subtract(ReadOnlySpan<double> left, ReadOnlySpan<double> right, Span<double> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<double>(left[index..]) - Vector256.Create<double>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] - right[index];
    }

    internal static void Multiply(ReadOnlySpan<double> left, ReadOnlySpan<double> right, Span<double> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<double>(left[index..]) * Vector256.Create<double>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] * right[index];
    }

    internal static void Divide(ReadOnlySpan<double> left, ReadOnlySpan<double> right, Span<double> result)
    {
        var index = 0;
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<double>(left[index..]) / Vector256.Create<double>(right[index..])).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = left[index] / right[index];
    }

    // value * scalar per element, in that operand order.
    internal static void Scale(ReadOnlySpan<double> values, double scalar, Span<double> result)
    {
        var index = 0;
        var multiplier = Vector256.Create(scalar);
        for (; UseBlocks && index <= result.Length - BlockWidth; index += BlockWidth)
            (Vector256.Create<double>(values[index..]) * multiplier).CopyTo(result[index..]);
        for (; index < result.Length; index++)
            result[index] = values[index] * scalar;
    }
}
