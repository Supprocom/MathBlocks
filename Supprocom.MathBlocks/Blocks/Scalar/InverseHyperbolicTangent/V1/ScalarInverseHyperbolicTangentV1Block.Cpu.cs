namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.inverse-hyperbolic-tangent@1</c> mathematical operation.</summary>
    public static double InverseHyperbolicTangent(double value) => 0.5d * LogOnePlus(2d * value / (1d - value));
}
