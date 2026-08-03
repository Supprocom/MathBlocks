namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double GeometricMean(IReadOnlyList<double> values)
    {
        var logarithms = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            logarithms[index] = MathBlockScalar.NaturalLogarithm(values[index]);
        return MathBlockScalar.Exponential(Mean(logarithms));
    }
}
