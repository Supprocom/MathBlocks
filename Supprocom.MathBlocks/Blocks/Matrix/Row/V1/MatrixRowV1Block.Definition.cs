namespace Supprocom.MathBlocks;

internal static partial class StructuralMathBlocks
{
    internal static class MatrixRowV1Block
    {
        internal const string Identity = "matrix.row@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MatrixRowV1BlockCpu.Create();
    }
}
