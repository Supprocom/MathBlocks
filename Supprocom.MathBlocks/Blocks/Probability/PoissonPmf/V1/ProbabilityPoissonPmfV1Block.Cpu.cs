
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>probability.poisson-pmf@1</c> mathematical operation.</summary>
    public static float PoissonPmf(float rate, int count) => rate == 0f ? count == 0 ? 1f : 0f : Math.Exp(-rate + count * Math.Log(rate) - MathBlockProbability.LogGamma(count + 1f));
}
