namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static double[] MinimumAssignment(MathBlockMatrix cost)
    {
        var size = cost.Rows;
        var stateCount = 1 << size;
        var values = MathBlockCollectionPrimitives.Repeat(Math.PositiveInfinity, stateCount);
        var previousMask = new int[stateCount];
        var chosenColumn = new int[stateCount];
        values[0] = 0d;
        for (var mask = 0; mask < stateCount; mask++)
        {
            var row = Math.PopulationCount((uint)mask);
            if (row >= size || !Math.IsFinite(values[mask]))
                continue;
            for (var column = 0; column < size; column++)
            {
                if ((mask & (1 << column)) != 0)
                    continue;
                var next = mask | (1 << column);
                var candidate = values[mask] + cost[row, column];
                if (candidate >= values[next])
                    continue;
                values[next] = candidate;
                previousMask[next] = mask;
                chosenColumn[next] = column;
            }
        }

        var result = new double[size];
        var current = stateCount - 1;
        for (var row = size - 1; row >= 0; row--)
        {
            result[row] = chosenColumn[current];
            current = previousMask[current];
        }

        return result;
    }
}
