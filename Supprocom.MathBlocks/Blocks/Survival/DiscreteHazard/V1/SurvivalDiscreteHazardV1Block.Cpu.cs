
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] DiscreteHazard(IReadOnlyList<double> probabilities)
    {
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
