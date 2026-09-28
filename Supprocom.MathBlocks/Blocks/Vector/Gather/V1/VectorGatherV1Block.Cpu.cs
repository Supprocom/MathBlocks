
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>vector.gather@1</c> mathematical operation.</summary>
    public static double[] Gather(IReadOnlyList<double> values, IReadOnlyList<double> indices)
    {
        ArgumentNullException.ThrowIfNull(indices);
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[indices.Count];
        for (var index = 0; index < indices.Count; index++)
            result[index] = values[(int)indices[index]];
        return result;
    }
}
