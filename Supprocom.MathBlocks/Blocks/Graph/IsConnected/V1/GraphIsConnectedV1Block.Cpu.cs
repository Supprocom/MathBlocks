namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static bool IsConnected(MathBlockGraph graph) => ConnectedComponentCount(graph) == 1;
}
