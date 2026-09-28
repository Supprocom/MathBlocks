
namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Structure contract.</summary>
public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>boolean-vector.true-indices@1</c> mathematical operation.</summary>
    public static double[] TrueIndices(IReadOnlyList<bool> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new List<double>();
        for (var index = 0; index < values.Count; index++)
            if (values[index])
                result.Add(index);
        return MathBlockCollectionPrimitives.Copy(result);
    }
}
