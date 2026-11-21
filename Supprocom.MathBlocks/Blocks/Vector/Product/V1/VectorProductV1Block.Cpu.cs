namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.product@1</c> mathematical operation.</summary>
    public static float Product(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var product = 1f;
        for (var index = 0; index < values.Count; index++)
            product *= values[index];
        return product;
    }
}
