namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.square-root@1</c> mathematical operation.</summary>
    public static float[] SquareRoot(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, Math.Sqrt);
    }
}
