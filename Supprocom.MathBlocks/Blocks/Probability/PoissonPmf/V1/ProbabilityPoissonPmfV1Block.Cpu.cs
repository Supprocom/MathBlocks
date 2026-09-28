
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>probability.poisson-pmf@1</c> mathematical operation.</summary>
    public static double PoissonPmf(double rate, int count) => rate == 0d ? count == 0 ? 1d : 0d : Math.Exp(-rate + count * Math.Log(rate) - MathBlockProbability.LogGamma(count + 1d));
}
