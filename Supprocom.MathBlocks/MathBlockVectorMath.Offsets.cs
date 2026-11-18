using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

// The reachability rules shared by the offset operations (sequence.first-true-offset, sequence.sum-over-offsets and
// sequence.maximum-over-offsets). counts[t] is the number of contiguous rows before row t, so row t + k is chained to row t when
// t + k lies in the series and counts[t + k] >= k, and row t - k is chained to row t when counts[t] >= k.
public static partial class MathBlockVectorMath
{
    // The counts are non-negative integers (a Vector never holds a non-finite value).
    internal static bool CountsAreValid(ReadOnlySpan<double> counts)
    {
        var index = 0;
        if (MathBlockSimd.UseBlocks)
        {
            // Four counts at a time, with the same test as the loop below: negative, or not equal to its own truncation (which a NaN is not).
            var broken = Vector256<double>.Zero;
            for (; index <= counts.Length - MathBlockSimd.BlockWidth; index += MathBlockSimd.BlockWidth)
            {
                var block = Vector256.Create<double>(counts[index..]);
                broken |= Vector256.LessThan(block, Vector256<double>.Zero) | ~Vector256.Equals(block, Vector256.Truncate(block));
            }

            if (broken.ExtractMostSignificantBits() != 0u)
                return false;
        }

        for (; index < counts.Length; index++)
        {
            var count = counts[index];
            if (count < 0d || count != Math.Truncate(count))
                return false;
        }
        return true;
    }

    // An offset is an integer scalar that fits an int32 without its extreme negative value.
    internal static bool TryReadOffset(double value, out int offset)
    {
        offset = 0;
        if (value != Math.Truncate(value) || Math.Abs(value) > int.MaxValue)
            return false;
        offset = (int)value;
        return true;
    }

    // Row row + offset exists and is chained to row: for a later row by the counts at that row, for an earlier row by the counts at row.
    internal static bool OffsetIsReachable(ReadOnlySpan<double> counts, int row, long offset)
    {
        var target = row + offset;
        if (target < 0 || target >= counts.Length)
            return false;
        return offset < 0 ? counts[row] >= -offset : counts[(int)target] >= offset;
    }

    // Every row from row + start to row + end exists and is chained to row: counts[row] covers the rows before it, and the last
    // later row (row + end, or row itself when end is negative) covers every row up to it.
    internal static bool OffsetSpanIsReachable(ReadOnlySpan<double> counts, int row, int start, int end)
    {
        long before = start < 0 ? -(long)start : 0L;
        long after = end > 0 ? end : 0L;
        if (row + (long)start < 0 || counts[row] < before)
            return false;
        var last = row + after;
        return last < counts.Length && counts[(int)last] >= after;
    }
}
