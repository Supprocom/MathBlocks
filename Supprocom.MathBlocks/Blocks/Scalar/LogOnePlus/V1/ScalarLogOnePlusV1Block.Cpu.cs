namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double LogOnePlus(double value)
    {
        var sum = 1d + value;
        return sum == 1d ? value : DeterministicNaturalLogarithm(sum) - ((sum - 1d) - value) / sum;
    }
}
