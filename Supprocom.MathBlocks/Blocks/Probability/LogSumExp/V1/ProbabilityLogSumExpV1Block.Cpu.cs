namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>probability.log-sum-exp@1</c> mathematical operation.</summary>
    public static float LogSumExp(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var maximum = MathBlockVectorMath.Maximum(values);
        var sum = 0f;
        for (var index = 0; index < values.Count; index++)
            sum += Math.Exp(values[index] - maximum);
        return maximum + Math.Log(sum);
    }
}
