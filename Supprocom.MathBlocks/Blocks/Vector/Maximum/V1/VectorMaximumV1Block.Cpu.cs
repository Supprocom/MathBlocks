namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.maximum@1</c> mathematical operation.</summary>
    public static double Maximum(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = values[0];
        for (var index = 1; index < values.Count; index++)
            result = Math.Max(result, values[index]);
        return result;
    }
}
