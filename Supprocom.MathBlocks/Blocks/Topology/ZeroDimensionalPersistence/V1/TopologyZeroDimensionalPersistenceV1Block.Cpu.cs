namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double[] ZeroDimensionalPersistence(IReadOnlyList<MathBlockPoint> points)
    {
        if (points.Count <= 1)
            return[];
        var edges = new List<MathBlockGraphEdge>(points.Count * (points.Count - 1) / 2);
        for (var left = 0; left < points.Count; left++)
            for (var right = left + 1; right < points.Count; right++)
                edges.Add(new MathBlockGraphEdge(left, right, Distance(points[left], points[right])));
        var forest = MathBlockGraphMath.MinimumSpanningForest(new MathBlockGraph(points.Count, edges));
        var weights = new double[forest.Count];
        for (var index = 0; index < forest.Count; index++)
            weights[index] = forest[index].Weight;
        MathBlockCollectionPrimitives.StableMergeSort(
            weights,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        return weights;
    }
}
