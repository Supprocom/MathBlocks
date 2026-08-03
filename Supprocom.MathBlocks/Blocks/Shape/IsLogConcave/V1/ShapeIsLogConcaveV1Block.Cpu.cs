
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static bool IsLogConcave(IReadOnlyList<double> values)
    {
        if (MathBlockCollectionPrimitives.Any(values, value => value < 0d))
            return false;
        for (var index = 1; index < values.Count - 1; index++)
            if (values[index] * values[index] < values[index - 1] * values[index + 1])
                return false;
        return true;
    }
}
