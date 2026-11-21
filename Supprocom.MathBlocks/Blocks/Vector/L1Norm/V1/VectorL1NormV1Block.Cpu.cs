namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.l1-norm@1</c> mathematical operation.</summary>
    public static float L1Norm(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var absolute = new float[values.Count];
        for (var index = 0; index < values.Count; index++)
            absolute[index] = Math.Abs(values[index]);
        return Sum(absolute);
    }
}
