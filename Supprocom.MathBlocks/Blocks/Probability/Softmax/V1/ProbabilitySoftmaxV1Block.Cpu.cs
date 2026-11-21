namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>probability.softmax@1</c> mathematical operation.</summary>
    public static float[] Softmax(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var maximum = MathBlockVectorMath.Maximum(values);
        var exponentials = new float[values.Count];
        for (var index = 0; index < values.Count; index++)
            exponentials[index] = Math.Exp(values[index] - maximum);
        return Normalize(exponentials);
    }
}
