namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingQuantile(IReadOnlyList<double> values, int width, double probability)
    {
        var result = new double[values.Count - width + 1];
        if (width == 1)
        {
            for (var index = 0; index < result.Length; index++)
                result[index] = values[index];
            return result;
        }
        if (probability is 0d or 1d)
        {
            var deque = new int[values.Count];
            var head = 0;
            var tail = 0;
            var minimum = probability == 0d;
            for (var index = 0; index < values.Count; index++)
            {
                while (head < tail && deque[head] <= index - width)
                    head++;
                while (head < tail && (minimum
                    ? values[deque[tail - 1]] >= values[index]
                    : values[deque[tail - 1]] <= values[index]))
                {
                    tail--;
                }
                deque[tail++] = index;
                if (index >= width - 1)
                    result[index - width + 1] = values[deque[head]];
            }
            return result;
        }

        var position = probability * (width - 1);
        var lowerIndex = (int)Math.Floor(position);
        var upperIndex = (int)Math.Ceiling(position);
        var weight = position - lowerIndex;
        var heaps = new RollingOrderStatisticHeaps(values, width, lowerIndex + 1);
        for (var start = 0; start < result.Length; start++)
        {
            var lower = heaps.LowerValue;
            var upper = lowerIndex == upperIndex ? lower : heaps.UpperValue;
            result[start] = lower * (1d - weight) + upper * weight;
            if (start + 1 != result.Length)
                heaps.Slide(start, start + width);
        }
        return result;
    }

    private sealed class RollingOrderStatisticHeaps
    {
        private readonly IReadOnlyList<double> values;
        private readonly int targetLowerCount;
        private readonly int[] lower;
        private readonly int[] upper;
        private readonly int[] positions;
        private readonly sbyte[] kinds;
        private int lowerCount;
        private int upperCount;

        public RollingOrderStatisticHeaps(
            IReadOnlyList<double> values,
            int width,
            int targetLowerCount)
        {
            this.values = values;
            this.targetLowerCount = targetLowerCount;
            lower = new int[width];
            upper = new int[width];
            positions = new int[values.Count];
            kinds = new sbyte[values.Count];
            for (var index = 0; index < positions.Length; index++)
            {
                positions[index] = -1;
                kinds[index] = -1;
            }
            for (var index = 0; index < width; index++)
            {
                Insert(index);
                Rebalance(Math.Min(targetLowerCount, index + 1));
            }
        }

        public double LowerValue => values[lower[0]];
        public double UpperValue => values[upper[0]];

        public void Slide(int outgoing, int incoming)
        {
            if (kinds[outgoing] == 0)
                Remove(lower, ref lowerCount, outgoing, maximum: true);
            else
                Remove(upper, ref upperCount, outgoing, maximum: false);
            Insert(incoming);
            Rebalance(targetLowerCount);
        }

        private void Insert(int item)
        {
            if (lowerCount == 0 && upperCount == 0)
                Insert(lower, ref lowerCount, item, 0, maximum: true);
            else if (lowerCount == 0)
                Insert(upper, ref upperCount, item, 1, maximum: false);
            else if (Compare(item, lower[0]) <= 0)
                Insert(lower, ref lowerCount, item, 0, maximum: true);
            else
                Insert(upper, ref upperCount, item, 1, maximum: false);
        }

        private void Rebalance(int requiredLowerCount)
        {
            while (lowerCount > requiredLowerCount)
            {
                var item = lower[0];
                Remove(lower, ref lowerCount, item, maximum: true);
                Insert(upper, ref upperCount, item, 1, maximum: false);
            }
            while (lowerCount < requiredLowerCount)
            {
                var item = upper[0];
                Remove(upper, ref upperCount, item, maximum: false);
                Insert(lower, ref lowerCount, item, 0, maximum: true);
            }
        }

        private void Insert(
            int[] heap,
            ref int count,
            int item,
            sbyte kind,
            bool maximum)
        {
            var position = count++;
            heap[position] = item;
            positions[item] = position;
            kinds[item] = kind;
            SiftUp(heap, position, maximum);
        }

        private void Remove(int[] heap, ref int count, int item, bool maximum)
        {
            var position = positions[item];
            var replacement = heap[--count];
            positions[item] = -1;
            kinds[item] = -1;
            if (position >= count)
                return;
            heap[position] = replacement;
            positions[replacement] = position;
            if (position > 0 && Precedes(heap[position], heap[(position - 1) >> 1], maximum))
                SiftUp(heap, position, maximum);
            else
                SiftDown(heap, count, position, maximum);
        }

        private void SiftUp(int[] heap, int position, bool maximum)
        {
            while (position > 0)
            {
                var parent = (position - 1) >> 1;
                if (!Precedes(heap[position], heap[parent], maximum))
                    return;
                Swap(heap, position, parent);
                position = parent;
            }
        }

        private void SiftDown(int[] heap, int count, int position, bool maximum)
        {
            while (true)
            {
                var left = position * 2 + 1;
                if (left >= count)
                    return;
                var right = left + 1;
                var selected = right < count && Precedes(heap[right], heap[left], maximum)
                    ? right
                    : left;
                if (!Precedes(heap[selected], heap[position], maximum))
                    return;
                Swap(heap, position, selected);
                position = selected;
            }
        }

        private bool Precedes(int left, int right, bool maximum)
        {
            var comparison = Compare(left, right);
            return maximum ? comparison > 0 : comparison < 0;
        }

        private int Compare(int left, int right)
        {
            var comparison = MathBlockCollectionPrimitives.CompareDoubleAscending(
                values[left],
                values[right]);
            return comparison != 0 ? comparison : left.CompareTo(right);
        }

        private void Swap(int[] heap, int left, int right)
        {
            (heap[left], heap[right]) = (heap[right], heap[left]);
            positions[heap[left]] = left;
            positions[heap[right]] = right;
        }
    }
}
