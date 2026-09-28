namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.mean@1</c> mathematical operation.</summary>
    public static double Mean(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Sum(values) / values.Count;
    }
}
