
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>probability.poisson-cdf@1</c> mathematical operation.</summary>
    public static double PoissonCdf(double rate, int count)
    {
        var sum = 0d;
        for (var index = 0; index <= count; index++)
            sum += PoissonPmf(rate, index);
        return sum;
    }
}
