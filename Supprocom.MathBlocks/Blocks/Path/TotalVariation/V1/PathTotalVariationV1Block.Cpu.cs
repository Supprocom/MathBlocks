
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.total-variation@1</c> mathematical operation.</summary>
    public static double TotalVariation(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = 0d;
        for (var index = 1; index < values.Count; index++)
            result += Math.Abs(values[index] - values[index - 1]);
        return result;
    }
}
