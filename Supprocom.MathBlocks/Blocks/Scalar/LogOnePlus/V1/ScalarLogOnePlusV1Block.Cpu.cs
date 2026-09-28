namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.log-one-plus@1</c> mathematical operation.</summary>
    public static double LogOnePlus(double value)
    {
        var sum = 1d + value;
        return sum == 1d ? value : DeterministicNaturalLogarithm(sum) - ((sum - 1d) - value) / sum;
    }
}
