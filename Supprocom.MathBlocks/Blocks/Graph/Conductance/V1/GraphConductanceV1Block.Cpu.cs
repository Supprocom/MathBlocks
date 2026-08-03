namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double Conductance(MathBlockGraph graph, IReadOnlyList<bool> subset)
    {
        var cut = 0d;
        var leftVolume = 0d;
        var rightVolume = 0d;
        foreach (var edge in graph)
        {
            if (subset[edge.From])
                leftVolume += edge.Weight;
            else
                rightVolume += edge.Weight;
            if (subset[edge.To])
                leftVolume += edge.Weight;
            else
                rightVolume += edge.Weight;
            if (subset[edge.From] != subset[edge.To])
                cut += edge.Weight;
        }

        return cut / Math.Min(leftVolume, rightVolume);
    }
}
