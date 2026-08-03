namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Power(IReadOnlyList<double> values, double exponent) => Map(values, value => MathBlockScalar.Power(value, exponent));
}
