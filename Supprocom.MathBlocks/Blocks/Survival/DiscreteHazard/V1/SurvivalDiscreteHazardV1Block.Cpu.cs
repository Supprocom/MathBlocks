
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>survival.discrete-hazard@1</c> mathematical operation.</summary>
    public static float[] DiscreteHazard(IReadOnlyList<float> probabilities)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        var result = new float[probabilities.Count];
        var survival = 1f;
        for (var index = 0; index < probabilities.Count; index++)
        {
            result[index] = probabilities[index] / survival;
            survival -= probabilities[index];
        }

        return result;
    }
}
