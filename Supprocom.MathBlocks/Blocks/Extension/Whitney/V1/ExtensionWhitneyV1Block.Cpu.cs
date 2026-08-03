
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] WhitneyExtension(IReadOnlyList<double> locations, IReadOnlyList<double> values, IReadOnlyList<double> queries, double lipschitz)
    {
        var result = new double[queries.Count];
        for (var query = 0; query < queries.Count; query++)
        {
            result[query] = Math.NegativeInfinity;
            for (var index = 0; index < locations.Count; index++)
                result[query] = Math.Max(result[query], values[index] - lipschitz * Math.Abs(queries[query] - locations[index]));
        }

        return result;
    }
}
