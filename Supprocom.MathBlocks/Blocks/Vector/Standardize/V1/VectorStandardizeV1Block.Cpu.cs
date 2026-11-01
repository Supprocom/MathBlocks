namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.standardize@1</c> mathematical operation.</summary>
    public static double[] Standardize(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var mean = Mean(values);
        var variance = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            variance += difference * difference;
        }

        variance /= values.Count;
        // A variance that overflows would divide every difference by an infinity and give zeros; every element is then NaN (invalid).
        var deviation = Math.IsFinite(variance) ? Math.Sqrt(variance) : Math.NaN;
        return Map(values, value => (value - mean) / deviation);
    }
}
