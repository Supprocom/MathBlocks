
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double SimplicialDepth(IReadOnlyList<MathBlockPoint> sample, MathBlockPoint point)
    {
        var containing = 0;
        var total = 0;
        for (var first = 0; first < sample.Count; first++)
        {
            for (var second = first + 1; second < sample.Count; second++)
            {
                for (var third = second + 1; third < sample.Count; third++)
                {
                    total++;
                    var coordinates = MathBlockGeometry.BarycentricCoordinates(point, sample[first], sample[second], sample[third]);
                    if (MathBlockCollectionPrimitives.All(coordinates, value => value >= 0d && value <= 1d))
                        containing++;
                }
            }
        }

        return (double)containing / total;
    }
}
