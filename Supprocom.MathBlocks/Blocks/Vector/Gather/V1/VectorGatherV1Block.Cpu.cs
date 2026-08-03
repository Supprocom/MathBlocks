
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static double[] Gather(IReadOnlyList<double> values, IReadOnlyList<double> indices)
    {
        var result = new double[indices.Count];
        for (var index = 0; index < indices.Count; index++)
            result[index] = values[(int)indices[index]];
        return result;
    }
}
