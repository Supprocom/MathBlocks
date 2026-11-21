namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ShapeLeastConcaveMajorantV1Block
    {
        internal const string Identity = "shape.least-concave-majorant@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("shape.least-concave-majorant", MathBlockAdvanced.LeastConcaveMajorant, MathBlockValue.Vector([0f, 0f, 2f]), [0f, 1f, 2f], SameVector);
    }
}
