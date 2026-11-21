
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>survival.product-limit@1</c> mathematical operation.</summary>
    public static float[] ProductLimitSurvival(IReadOnlyList<float> occurrences, IReadOnlyList<float> atRisk)
    {
        ArgumentNullException.ThrowIfNull(atRisk);
        ArgumentNullException.ThrowIfNull(occurrences);
        var result = new float[occurrences.Count];
        var survival = 1f;
        for (var index = 0; index < result.Length; index++)
        {
            survival *= 1f - occurrences[index] / atRisk[index];
            result[index] = survival;
        }

        return result;
    }
}
