namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.product@1</c> mathematical operation.</summary>
    public static double Product(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var product = 1d;
        for (var index = 0; index < values.Count; index++)
            product *= values[index];
        return product;
    }
}
