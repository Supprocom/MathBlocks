
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>vector.gather@1</c> mathematical operation.</summary>
    public static float[] Gather(IReadOnlyList<float> values, IReadOnlyList<float> indices)
    {
        ArgumentNullException.ThrowIfNull(indices);
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[indices.Count];
        for (var index = 0; index < indices.Count; index++)
            result[index] = values[(int)indices[index]];
        return result;
    }
}
