namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double[] Softmax(IReadOnlyList<double> values)
    {
        var maximum = MathBlockVectorMath.Maximum(values);
        var exponentials = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            exponentials[index] = Math.Exp(values[index] - maximum);
        return Normalize(exponentials);
    }
}
