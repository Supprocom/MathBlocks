namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ProbabilityPoissonCdfV1Block
    {
        internal const string Identity = "probability.poisson-cdf@1";
        internal static MathBlockOperation Create() => CreatePoisson("probability.poisson-cdf", MathBlockAdvanced.PoissonCdf, 3d * Math.Exp(-2d), count: 1);
    }
}
