namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.log-one-plus@1</c> mathematical operation.</summary>
    public static float LogOnePlus(float value)
    {
        var sum = 1f + value;
        return sum == 1f ? value : DeterministicNaturalLogarithm(sum) - ((sum - 1f) - value) / sum;
    }
}
