
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>survival.product-limit@1</c> mathematical operation.</summary>
    public static double[] ProductLimitSurvival(IReadOnlyList<double> occurrences, IReadOnlyList<double> atRisk)
    {
        ArgumentNullException.ThrowIfNull(atRisk);
        ArgumentNullException.ThrowIfNull(occurrences);
        var result = new double[occurrences.Count];
        var survival = 1d;
        for (var index = 0; index < result.Length; index++)
        {
            survival *= 1d - occurrences[index] / atRisk[index];
            result[index] = survival;
        }

        return result;
    }
}
