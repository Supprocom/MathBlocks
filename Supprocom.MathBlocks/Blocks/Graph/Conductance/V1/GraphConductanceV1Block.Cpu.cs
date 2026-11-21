namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.conductance@1</c> mathematical operation.</summary>
    public static float Conductance(MathBlockGraph graph, IReadOnlyList<bool> subset)
    {
        ArgumentNullException.ThrowIfNull(graph);
        ArgumentNullException.ThrowIfNull(subset);
        var cut = 0f;
        var leftVolume = 0f;
        var rightVolume = 0f;
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
