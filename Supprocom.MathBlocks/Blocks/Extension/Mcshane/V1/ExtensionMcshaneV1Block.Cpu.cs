
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>extension.mcshane@1</c> mathematical operation.</summary>
    public static double[] McShaneExtension(IReadOnlyList<double> locations, IReadOnlyList<double> values, IReadOnlyList<double> queries, double lipschitz)
    {
        ArgumentNullException.ThrowIfNull(locations);
        ArgumentNullException.ThrowIfNull(queries);
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[queries.Count];
        for (var query = 0; query < queries.Count; query++)
        {
            result[query] = Math.PositiveInfinity;
            for (var index = 0; index < locations.Count; index++)
                result[query] = Math.Min(result[query], values[index] + lipschitz * Math.Abs(queries[query] - locations[index]));
        }

        return result;
    }
}
