namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.cumulative-product@1</c> mathematical operation.</summary>
    public static float[] CumulativeProduct(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count];
        var product = 1f;
        for (var index = 0; index < values.Count; index++)
        {
            product *= values[index];
            result[index] = product;
        }

        return result;
    }
}
