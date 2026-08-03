namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double LogSumExp(IReadOnlyList<double> values)
    {
        var maximum = MathBlockVectorMath.Maximum(values);
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
            sum += Math.Exp(values[index] - maximum);
        return maximum + Math.Log(sum);
    }
}
