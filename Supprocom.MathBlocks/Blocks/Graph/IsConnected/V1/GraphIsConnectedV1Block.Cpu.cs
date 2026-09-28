namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.is-connected@1</c> mathematical operation.</summary>
    public static bool IsConnected(MathBlockGraph graph) => ConnectedComponentCount(graph) == 1;
}
