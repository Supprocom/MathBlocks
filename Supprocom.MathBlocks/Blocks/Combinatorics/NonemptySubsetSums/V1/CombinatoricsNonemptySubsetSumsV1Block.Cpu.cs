namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double[] NonemptySubsetSums(IReadOnlyList<double> values)
    {
        var count = (1 << values.Count) - 1;
        var result = new double[count];
        for (var mask = 1; mask <= count; mask++)
        {
            var sum = 0d;
            for (var index = 0; index < values.Count; index++)
                if ((mask & (1 << index)) != 0)
                    sum += values[index];
            result[mask - 1] = sum;
        }

        return result;
    }
}
