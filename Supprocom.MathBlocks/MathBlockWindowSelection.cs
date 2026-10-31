namespace Supprocom.MathBlocks;

// Sliding selection for the window.vector.minimum, maximum, arg-minimum, arg-maximum, median and quantile forms.
// Selection does no arithmetic on the values, and each structure orders the window exactly as its source does, so
// every row has the bits of the source evaluated on that window.
// The code is plain loops over arrays and indexes, one series at a time, so a per-thread CUDA function can mirror it.
internal static class MathBlockWindowSelection
{
    // Monotone deque (Lemire, "Streaming maximum-minimum filter using no more than three comparisons per element",
    // 2006). The deque holds input indexes whose order keys are monotone from head to tail, so the head is the
    // window's extreme.
    // vector.minimum and vector.maximum fold Math.Min and Math.Max (MathBlockPrimitives), which return -0 (+0) for
    // equal zeros of either sign. The value deques
    // compare TotalOrderKey, which orders every finite double the same way, so the head is the folded result.
    // vector.arg-minimum and vector.arg-maximum keep the first index whose value compares strictly lower (higher),
    // with -0 equal to +0. The position deques pop only strictly worse values, so among equal values the earliest
    // stays at the head.
    internal static void RunExtreme(
        ReadOnlySpan<double> x,
        int count,
        int width,
        double fill,
        bool maximum,
        bool position,
        double[]? values,
        bool[]? valid)
    {
        var deque = new int[width];
        var head = 0;
        var size = 0;
        for (var row = 0; row < count; row++)
        {
            // The deque is a ring of capacity width: it never holds more than the indexes of one window.
            if (size > 0 && deque[head] <= row - width)
            {
                head = head + 1 == width ? 0 : head + 1;
                size--;
            }
            var value = x[row];
            while (size > 0)
            {
                var tail = head + size - 1;
                if (tail >= width)
                    tail -= width;
                var last = x[deque[tail]];
                bool pop;
                if (position)
                    pop = maximum ? last < value : last > value;
                else
                    pop = maximum
                        ? TotalOrderKey(last) <= TotalOrderKey(value)
                        : TotalOrderKey(last) >= TotalOrderKey(value);
                if (!pop)
                    break;
                size--;
            }
            var slot = head + size;
            if (slot >= width)
                slot -= width;
            deque[slot] = row;
            size++;
            if (row < width - 1)
            {
                Store(values, valid, row, fill, 0d, false);
                continue;
            }
            var extreme = deque[head];
            Store(values, valid, row, fill, position ? extreme - (row - width + 1) : x[extreme], true);
        }
    }

    // Sliding order statistics for vector.quantile: Quantile sorts the window with a stable merge sort under
    // CompareDoubleAscending (-0 equal to +0), so its sorted position k holds the k-th smallest element under the
    // order (value, index). Two indexed heaps keep that order over the sliding window, as sequence.rolling-quantile
    // does: a max-heap with the lower + 1 smallest elements and a min-heap with the rest. Their heads are sorted
    // positions lower and lower + 1. The interpolation is the source's expression on those two elements.
    // Heap entries are input indexes; an index's heap position and side are stored at index % width, because the
    // live indexes of one window are width consecutive integers.
    internal static void RunQuantile(
        ReadOnlySpan<double> x,
        int count,
        int width,
        double probability,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        if (probability is not (>= 0d and <= 1d))
        {
            for (var row = 0; row < count; row++)
                Store(values, valid, row, fill, 0d, false);
            return;
        }
        for (var row = 0; row < width - 1; row++)
            Store(values, valid, row, fill, 0d, false);
        if (width == 1)
        {
            for (var row = 0; row < count; row++)
                Store(values, valid, row, fill, x[row], true);
            return;
        }

        var position = probability * (width - 1);
        var lowerIndex = (int)Math.Floor(position);
        var upperIndex = (int)Math.Ceiling(position);
        var weight = position - lowerIndex;
        var target = lowerIndex + 1;
        var heaps = new OrderStatisticHeaps(width);
        for (var row = 0; row < count; row++)
        {
            if (row >= width)
                heaps.Remove(x, row - width);
            heaps.Insert(x, row);
            heaps.Rebalance(x, Math.Min(target, row + 1));
            if (row < width - 1)
                continue;
            var lower = x[heaps.Lower[0]];
            var upper = lowerIndex == upperIndex ? lower : x[heaps.Upper[0]];
            var result = lower * (1d - weight) + upper * weight;
            Store(values, valid, row, fill, result, double.IsFinite(result));
        }
    }

    // Maps a finite double to an integer key whose signed order is the IEEE 754 total order, with -0 before +0.
    internal static long TotalOrderKey(double value)
    {
        var bits = BitConverter.DoubleToInt64Bits(value);
        return bits >= 0 ? bits : bits ^ long.MaxValue;
    }

    private static void Store(double[]? values, bool[]? valid, int row, double fill, double value, bool computed)
    {
        if (values is not null)
            values[row] = computed ? value : fill;
        if (valid is not null)
            valid[row] = computed;
    }

    // Lower is a max-heap and Upper a min-heap under Compare. Positions[i % width] is index i's position in its
    // heap and Sides[i % width] its heap: 0 for Lower, 1 for Upper.
    private sealed class OrderStatisticHeaps
    {
        private readonly int width;
        private readonly int[] positions;
        private readonly int[] sides;
        private int lowerCount;
        private int upperCount;

        internal OrderStatisticHeaps(int width)
        {
            this.width = width;
            Lower = new int[width];
            Upper = new int[width];
            positions = new int[width];
            sides = new int[width];
        }

        internal int[] Lower { get; }

        internal int[] Upper { get; }

        internal void Insert(ReadOnlySpan<double> x, int item)
        {
            if (lowerCount == 0 && upperCount == 0)
                Push(x, Lower, ref lowerCount, item, 0, true);
            else if (lowerCount == 0)
                Push(x, Upper, ref upperCount, item, 1, false);
            else if (Compare(x, item, Lower[0]) <= 0)
                Push(x, Lower, ref lowerCount, item, 0, true);
            else
                Push(x, Upper, ref upperCount, item, 1, false);
        }

        internal void Remove(ReadOnlySpan<double> x, int item)
        {
            if (sides[item % width] == 0)
                Remove(x, Lower, ref lowerCount, item, true);
            else
                Remove(x, Upper, ref upperCount, item, false);
        }

        internal void Rebalance(ReadOnlySpan<double> x, int lowerTarget)
        {
            while (lowerCount > lowerTarget)
            {
                var item = Lower[0];
                Remove(x, Lower, ref lowerCount, item, true);
                Push(x, Upper, ref upperCount, item, 1, false);
            }
            while (lowerCount < lowerTarget)
            {
                var item = Upper[0];
                Remove(x, Upper, ref upperCount, item, false);
                Push(x, Lower, ref lowerCount, item, 0, true);
            }
        }

        private static int Compare(ReadOnlySpan<double> x, int left, int right)
        {
            var comparison = MathBlockCollectionPrimitives.CompareDoubleAscending(x[left], x[right]);
            return comparison != 0 ? comparison : left.CompareTo(right);
        }

        private static bool Precedes(ReadOnlySpan<double> x, int left, int right, bool maximum)
        {
            var comparison = Compare(x, left, right);
            return maximum ? comparison > 0 : comparison < 0;
        }

        private void Push(ReadOnlySpan<double> x, int[] heap, ref int heapCount, int item, int side, bool maximum)
        {
            var position = heapCount++;
            heap[position] = item;
            positions[item % width] = position;
            sides[item % width] = side;
            SiftUp(x, heap, position, maximum);
        }

        private void Remove(ReadOnlySpan<double> x, int[] heap, ref int heapCount, int item, bool maximum)
        {
            var position = positions[item % width];
            var replacement = heap[--heapCount];
            if (position >= heapCount)
                return;
            heap[position] = replacement;
            positions[replacement % width] = position;
            if (position > 0 && Precedes(x, heap[position], heap[(position - 1) >> 1], maximum))
                SiftUp(x, heap, position, maximum);
            else
                SiftDown(x, heap, heapCount, position, maximum);
        }

        private void SiftUp(ReadOnlySpan<double> x, int[] heap, int position, bool maximum)
        {
            while (position > 0)
            {
                var parent = (position - 1) >> 1;
                if (!Precedes(x, heap[position], heap[parent], maximum))
                    return;
                Swap(heap, position, parent);
                position = parent;
            }
        }

        private void SiftDown(ReadOnlySpan<double> x, int[] heap, int heapCount, int position, bool maximum)
        {
            while (true)
            {
                var left = position * 2 + 1;
                if (left >= heapCount)
                    return;
                var right = left + 1;
                var selected = right < heapCount && Precedes(x, heap[right], heap[left], maximum) ? right : left;
                if (!Precedes(x, heap[selected], heap[position], maximum))
                    return;
                Swap(heap, position, selected);
                position = selected;
            }
        }

        private void Swap(int[] heap, int left, int right)
        {
            (heap[left], heap[right]) = (heap[right], heap[left]);
            positions[heap[left] % width] = left;
            positions[heap[right] % width] = right;
        }
    }
}
