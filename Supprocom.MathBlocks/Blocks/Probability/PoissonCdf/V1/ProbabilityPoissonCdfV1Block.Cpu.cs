
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double PoissonCdf(double rate, int count)
    {
        var sum = 0d;
        for (var index = 0; index <= count; index++)
            sum += PoissonPmf(rate, index);
        return sum;
    }
}
