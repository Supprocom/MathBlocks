namespace Supprocom.MathBlocks;

internal static class MathBlockCollectionPrimitives
{
    public static int CompareDoubleAscending(double left, double right) =>
        left < right ? -1 : left > right ? 1 : 0;

    public static int CompareDoubleDescending(double left, double right) =>
        left > right ? -1 : left < right ? 1 : 0;

    public static T[] Copy<T>(IReadOnlyList<T> values)
    {
        var result = new T[values.Count];
        for (var index = 0; index < values.Count; index++)
            result[index] = values[index];
        return result;
    }

    public static T[] CopyEnumerable<T>(IEnumerable<T> values)
    {
        var result = new T[4];
        var count = 0;
        foreach (var value in values)
        {
            if (count == result.Length)
            {
                if (result.Length > int.MaxValue / 2)
                    throw new InvalidOperationException("The sequence is too large.");
                var expanded = new T[result.Length * 2];
                for (var index = 0; index < count; index++)
                    expanded[index] = result[index];
                result = expanded;
            }
            result[count++] = value;
        }

        var exact = new T[count];
        for (var index = 0; index < count; index++)
            exact[index] = result[index];
        return exact;
    }

    public static TResult[] Map<TSource, TResult>(
        IReadOnlyList<TSource> values,
        Func<TSource, TResult> function)
    {
        var result = new TResult[values.Count];
        for (var index = 0; index < values.Count; index++)
            result[index] = function(values[index]);
        return result;
    }

    public static TResult[] MapIndexed<TSource, TResult>(
        IReadOnlyList<TSource> values,
        Func<TSource, int, TResult> function)
    {
        var result = new TResult[values.Count];
        for (var index = 0; index < values.Count; index++)
            result[index] = function(values[index], index);
        return result;
    }

    public static bool All<T>(IReadOnlyList<T> values, Func<T, bool> predicate)
    {
        for (var index = 0; index < values.Count; index++)
            if (!predicate(values[index]))
                return false;
        return true;
    }

    public static bool Any<T>(IReadOnlyList<T> values, Func<T, bool> predicate)
    {
        for (var index = 0; index < values.Count; index++)
            if (predicate(values[index]))
                return true;
        return false;
    }

    public static int Count<T>(IReadOnlyList<T> values, Func<T, bool> predicate)
    {
        var result = 0;
        for (var index = 0; index < values.Count; index++)
            if (predicate(values[index]))
                result++;
        return result;
    }

    public static int[] Range(int count)
    {
        var result = new int[count];
        for (var index = 0; index < count; index++)
            result[index] = index;
        return result;
    }

    public static T[] Repeat<T>(T value, int count)
    {
        var result = new T[count];
        for (var index = 0; index < count; index++)
            result[index] = value;
        return result;
    }

    public static T[] ConcatenateAfterFirst<T>(IReadOnlyList<T> left, IReadOnlyList<T> right)
    {
        var result = new T[left.Count + Math.Max(0, right.Count - 1)];
        for (var index = 0; index < left.Count; index++)
            result[index] = left[index];
        for (var index = 1; index < right.Count; index++)
            result[left.Count + index - 1] = right[index];
        return result;
    }

    public static T[] SortedCopy<T>(IReadOnlyList<T> values, Comparison<T> comparison)
    {
        var result = Copy(values);
        StableMergeSort(result, comparison);
        return result;
    }

    public static int[] SortedIndices<T>(IReadOnlyList<T> values, Comparison<T> comparison)
    {
        var result = Range(values.Count);
        StableMergeSort(result, (left, right) =>
        {
            var order = comparison(values[left], values[right]);
            return order != 0 ? order : left.CompareTo(right);
        });
        return result;
    }

    public static T[] DistinctSortedCopy<T>(
        IReadOnlyList<T> values,
        Comparison<T> comparison,
        Func<T, T, bool> equal)
    {
        var sorted = SortedCopy(values, comparison);
        if (sorted.Length < 2)
            return sorted;
        var count = 1;
        for (var index = 1; index < sorted.Length; index++)
            if (!equal(sorted[index], sorted[count - 1]))
                sorted[count++] = sorted[index];
        var result = new T[count];
        for (var index = 0; index < count; index++)
            result[index] = sorted[index];
        return result;
    }

    public static int[] SelectedIndices(int count, Func<int, bool> predicate)
    {
        var selected = new int[count];
        var selectedCount = 0;
        for (var index = 0; index < count; index++)
            if (predicate(index))
                selected[selectedCount++] = index;
        var result = new int[selectedCount];
        for (var index = 0; index < selectedCount; index++)
            result[index] = selected[index];
        return result;
    }

    public static void StableMergeSort<T>(T[] values, Comparison<T> comparison)
    {
        if (values.Length < 2)
            return;
        var scratch = new T[values.Length];
        var width = 1;
        while (true)
        {
            var start = 0;
            while (start < values.Length)
            {
                var remaining = values.Length - start;
                var middle = width < remaining ? start + width : values.Length;
                var pairWidth = width > int.MaxValue - width ? int.MaxValue : width + width;
                var end = pairWidth < remaining ? start + pairWidth : values.Length;
                var left = start;
                var right = middle;
                var output = start;
                while (left < middle && right < end)
                    scratch[output++] = comparison(values[left], values[right]) <= 0
                        ? values[left++]
                        : values[right++];
                while (left < middle)
                    scratch[output++] = values[left++];
                while (right < end)
                    scratch[output++] = values[right++];
                for (var index = start; index < end; index++)
                    values[index] = scratch[index];
                start = end;
            }

            if (width >= values.Length - width)
                return;
            width += width;
        }
    }
}
