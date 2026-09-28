namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.arg-maximum@1</c> mathematical operation.</summary>
    public static int ArgMaximum(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = 0;
        for (var index = 1; index < values.Count; index++)
            if (values[index] > values[result])
                result = index;
        return result;
    }
}
