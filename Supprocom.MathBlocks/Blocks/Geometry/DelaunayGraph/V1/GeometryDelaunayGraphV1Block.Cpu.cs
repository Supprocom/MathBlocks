namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static MathBlockGraph DelaunayGraph(IReadOnlyList<MathBlockPoint> points)
    {
        var edges = new List<(int Left, int Right)>();
        for (var first = 0; first < points.Count; first++)
        {
            for (var second = first + 1; second < points.Count; second++)
            {
                for (var third = second + 1; third < points.Count; third++)
                {
                    if (!TryCircumcircle(points[first], points[second], points[third], out var center, out var radiusSquare))
                        continue;
                    var empty = true;
                    for (var index = 0; index < points.Count; index++)
                    {
                        if (index == first || index == second || index == third)
                            continue;
                        var x = points[index].X - center.X;
                        var y = points[index].Y - center.Y;
                        if (x * x + y * y < radiusSquare)
                        {
                            empty = false;
                            break;
                        }
                    }

                    if (!empty)
                        continue;
                    AddUniqueEdge(edges, first, second);
                    AddUniqueEdge(edges, first, third);
                    AddUniqueEdge(edges, second, third);
                }
            }
        }

        if (edges.Count == 0 && points.Count > 1)
        {
            var ordered = MathBlockCollectionPrimitives.SortedIndices(points, CompareDelaunayPoints);
            for (var index = 1; index < ordered.Length; index++)
                AddUniqueEdge(edges, ordered[index - 1], ordered[index]);
        }

        var orderedEdges = MathBlockCollectionPrimitives.SortedCopy(
            edges,
            (left, right) => left.Left != right.Left
                ? left.Left.CompareTo(right.Left)
                : left.Right.CompareTo(right.Right));
        var result = new MathBlockGraphEdge[orderedEdges.Length];
        for (var index = 0; index < result.Length; index++)
        {
            var edge = orderedEdges[index];
            result[index] = new MathBlockGraphEdge(
                edge.Left,
                edge.Right,
                Distance(points[edge.Left], points[edge.Right]));
        }
        return new MathBlockGraph(points.Count, result);
    }

    private static int CompareDelaunayPoints(MathBlockPoint left, MathBlockPoint right)
    {
        if (left.X < right.X)
            return -1;
        if (left.X > right.X)
            return 1;
        return left.Y < right.Y ? -1 : left.Y > right.Y ? 1 : 0;
    }

    private static void AddUniqueEdge(List<(int Left, int Right)> edges, int first, int second)
    {
        var left = Math.Min(first, second);
        var right = Math.Max(first, second);
        for (var index = 0; index < edges.Count; index++)
            if (edges[index].Left == left && edges[index].Right == right)
                return;
        edges.Add((left, right));
    }
}
