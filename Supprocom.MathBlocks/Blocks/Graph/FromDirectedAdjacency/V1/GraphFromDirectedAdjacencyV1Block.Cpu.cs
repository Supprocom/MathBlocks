
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>graph.from-directed-adjacency@1</c> mathematical operation.</summary>
    public static MathBlockGraph DirectedGraphFromAdjacency(MathBlockMatrix adjacency)
    {
        ArgumentNullException.ThrowIfNull(adjacency);
        var edges = new List<MathBlockGraphEdge>();
        for (var row = 0; row < adjacency.Rows; row++)
            for (var column = 0; column < adjacency.Columns; column++)
                if (row != column && adjacency[row, column] != 0d)
                    edges.Add(new MathBlockGraphEdge(row, column, adjacency[row, column]));
        return new MathBlockGraph(adjacency.Rows, edges);
    }
}
