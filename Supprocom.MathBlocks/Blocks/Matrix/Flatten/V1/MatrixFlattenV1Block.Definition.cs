namespace Supprocom.MathBlocks;

internal static partial class StructuralMathBlocks
{
    internal static class MatrixFlattenV1Block
    {
        internal const string Identity = "matrix.flatten@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MatrixFlattenV1BlockCpu.Create();
    }
}
