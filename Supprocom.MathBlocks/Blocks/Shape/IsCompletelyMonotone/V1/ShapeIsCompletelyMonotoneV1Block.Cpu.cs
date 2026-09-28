
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>shape.is-completely-monotone@1</c> mathematical operation.</summary>
    public static bool IsCompletelyMonotone(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var differences = MathBlockCollectionPrimitives.Copy(values);
        for (var order = 0; order < values.Count; order++)
        {
            var sign = (order & 1) == 0 ? 1d : -1d;
            for (var index = 0; index < differences.Length; index++)
                if (sign * differences[index] < 0d)
                    return false;
            differences = MathBlockVectorMath.Difference(differences);
        }

        return true;
    }
}
