
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>statistics.pseudomedian@1</c> mathematical operation.</summary>
    public static float Pseudomedian(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var averages = new List<float>(values.Count * (values.Count + 1) / 2);
        for (var left = 0; left < values.Count; left++)
            for (var right = left; right < values.Count; right++)
                averages.Add((values[left] + values[right]) / 2f);
        return MathBlockVectorMath.Median(averages);
    }
}
