namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ProbabilityPoissonPmfV1Block
    {
        internal const string Identity = "probability.poisson-pmf@1";
        internal static MathBlockOperation Create() => CreatePoisson("probability.poisson-pmf", MathBlockAdvanced.PoissonPmf, Math.Exp(-2d));
    }
}
