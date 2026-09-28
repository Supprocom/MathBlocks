namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.geometric-mean@1</c> mathematical operation.</summary>
    public static double GeometricMean(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var logarithms = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            logarithms[index] = MathBlockScalar.NaturalLogarithm(values[index]);
        return MathBlockScalar.Exponential(Mean(logarithms));
    }
}
