namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.l1-norm@1</c> mathematical operation.</summary>
    public static double L1Norm(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var absolute = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            absolute[index] = Math.Abs(values[index]);
        return Sum(absolute);
    }
}
