
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static double[] TrueIndices(IReadOnlyList<bool> values)
    {
        var result = new List<double>();
        for (var index = 0; index < values.Count; index++)
            if (values[index])
                result.Add(index);
        return MathBlockCollectionPrimitives.Copy(result);
    }
}
