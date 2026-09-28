
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>survival.discrete-hazard@1</c> mathematical operation.</summary>
    public static double[] DiscreteHazard(IReadOnlyList<double> probabilities)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        var result = new double[probabilities.Count];
        var survival = 1d;
        for (var index = 0; index < probabilities.Count; index++)
        {
            result[index] = probabilities[index] / survival;
            survival -= probabilities[index];
        }

        return result;
    }
}
