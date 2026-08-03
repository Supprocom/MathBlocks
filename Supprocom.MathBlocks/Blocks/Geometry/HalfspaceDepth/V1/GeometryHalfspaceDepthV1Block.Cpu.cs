namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double HalfspaceDepth(IReadOnlyList<MathBlockPoint> sample, MathBlockPoint point)
    {
        if (sample.Count == 0)
            return Math.NaN;
        var coincident = 0;
        var vectors = new List<MathBlockPoint>(sample.Count);
        for (var index = 0; index < sample.Count; index++)
        {
            var x = sample[index].X - point.X;
            var y = sample[index].Y - point.Y;
            if (x == 0d && y == 0d)
            {
                coincident++;
                continue;
            }

            vectors.Add(new MathBlockPoint(x, y));
        }

        if (vectors.Count == 0)
            return 1d;
        var maximumOpenHalfplane = 0;
        for (var pivot = 0; pivot < vectors.Count; pivot++)
        {
            var count = 0;
            for (var index = 0; index < vectors.Count; index++)
            {
                var cross = vectors[pivot].X * vectors[index].Y - vectors[pivot].Y * vectors[index].X;
                var dot = vectors[pivot].X * vectors[index].X + vectors[pivot].Y * vectors[index].Y;
                if (cross > 0d || cross == 0d && dot > 0d)
                    count++;
            }

            maximumOpenHalfplane = Math.Max(maximumOpenHalfplane, count);
        }

        return (double)(coincident + vectors.Count - maximumOpenHalfplane) / sample.Count;
    }
}
