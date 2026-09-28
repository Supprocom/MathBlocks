
namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Advanced contract.</summary>
public static partial class MathBlockAdvanced
{

    private static double[] ShapeEnvelope(IReadOnlyList<double> values, bool concave)
    {
        var hull = new List<int>();
        for (var index = 0; index < values.Count; index++)
        {
            hull.Add(index);
            while (hull.Count >= 3)
            {
                var first = hull[^3];
                var middle = hull[^2];
                var last = hull[^1];
                var firstSlope = (values[middle] - values[first]) / (middle - first);
                var secondSlope = (values[last] - values[middle]) / (last - middle);
                if (concave ? firstSlope >= secondSlope : firstSlope <= secondSlope)
                    break;
                hull.RemoveAt(hull.Count - 2);
            }
        }
        var result = new double[values.Count];
        for (var segment = 1; segment < hull.Count; segment++)
        {
            var start = hull[segment - 1];
            var end = hull[segment];
            for (var index = start; index <= end; index++)
            {
                var weight = (double)(index - start) / (end - start);
                result[index] = values[start] * (1d - weight) + values[end] * weight;
            }
        }
        return result;
    }

    private static IEnumerable<int[]> Combinations(int count, int size)
    {
        var indices = MathBlockCollectionPrimitives.Range(size);
        while (true)
        {
            yield return MathBlockCollectionPrimitives.Copy(indices);
            var position = size - 1;
            while (position >= 0 && indices[position] == count - size + position)
                position--;
            if (position < 0)
                yield break;
            indices[position]++;
            for (var index = position + 1; index < size; index++)
                indices[index] = indices[index - 1] + 1;
        }
    }

    private static MathBlockMatrix Submatrix(
        MathBlockMatrix matrix,
        int[] rows,
        int[] columns)
    {
        var values = new double[rows.Length * columns.Length];
        for (var row = 0; row < rows.Length; row++)
            for (var column = 0; column < columns.Length; column++)
                values[row * columns.Length + column] = matrix[rows[row], columns[column]];
        return new MathBlockMatrix(rows.Length, columns.Length, values, true);
    }
}
