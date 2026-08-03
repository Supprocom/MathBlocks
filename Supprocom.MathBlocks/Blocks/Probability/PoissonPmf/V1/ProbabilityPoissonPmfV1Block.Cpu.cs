
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double PoissonPmf(double rate, int count) => rate == 0d ? count == 0 ? 1d : 0d : Math.Exp(-rate + count * Math.Log(rate) - MathBlockProbability.LogGamma(count + 1d));
}
