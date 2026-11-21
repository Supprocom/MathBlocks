namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.halfspace-depth@1</c> mathematical operation.</summary>
    public static float HalfspaceDepth(IReadOnlyList<MathBlockPoint> sample, MathBlockPoint point)
    {
        ArgumentNullException.ThrowIfNull(sample);
        if (sample.Count == 0)
            return Math.NaN;
        var coincident = 0;
        var vectors = new List<MathBlockPoint>(sample.Count);
        for (var index = 0; index < sample.Count; index++)
        {
            var x = sample[index].X - point.X;
            var y = sample[index].Y - point.Y;
            if (x == 0f && y == 0f)
            {
                coincident++;
                continue;
            }

            vectors.Add(new MathBlockPoint(x, y));
        }

        if (vectors.Count == 0)
            return 1f;
        var maximumOpenHalfplane = 0;
        for (var pivot = 0; pivot < vectors.Count; pivot++)
        {
            var count = 0;
            for (var index = 0; index < vectors.Count; index++)
            {
                var cross = vectors[pivot].X * vectors[index].Y - vectors[pivot].Y * vectors[index].X;
                var dot = vectors[pivot].X * vectors[index].X + vectors[pivot].Y * vectors[index].Y;
                // A NaN (inf - inf, 0 * inf from an overflowing product) fails both tests and would count the point as outside.
                if (Math.IsNaN(cross) || Math.IsNaN(dot))
                    return Math.NaN;
                if (cross > 0f || cross == 0f && dot > 0f)
                    count++;
            }

            maximumOpenHalfplane = Math.Max(maximumOpenHalfplane, count);
        }

        return (float)(coincident + vectors.Count - maximumOpenHalfplane) / sample.Count;
    }
}
