
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>shape.is-log-concave@1</c> mathematical operation.</summary>
    public static bool IsLogConcave(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        if (MathBlockCollectionPrimitives.Any(values, value => value < 0d))
            return false;
        for (var index = 1; index < values.Count - 1; index++)
            if (values[index] * values[index] < values[index - 1] * values[index + 1])
                return false;
        return true;
    }
}
