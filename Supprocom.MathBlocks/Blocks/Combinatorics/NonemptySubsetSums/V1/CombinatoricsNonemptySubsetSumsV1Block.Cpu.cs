namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>combinatorics.nonempty-subset-sums@1</c> mathematical operation.</summary>
    public static float[] NonemptySubsetSums(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var count = (1 << values.Count) - 1;
        var result = new float[count];
        for (var mask = 1; mask <= count; mask++)
        {
            var sum = 0f;
            for (var index = 0; index < values.Count; index++)
                if ((mask & (1 << index)) != 0)
                    sum += values[index];
            result[mask - 1] = sum;
        }

        return result;
    }
}
