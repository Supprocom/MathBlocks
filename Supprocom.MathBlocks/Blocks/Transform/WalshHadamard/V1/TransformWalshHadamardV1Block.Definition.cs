namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class TransformWalshHadamardV1Block
    {
        internal const string Identity = "transform.walsh-hadamard@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("transform.walsh-hadamard", MathBlockAdvanced.WalshHadamard, MathBlockValue.Vector([1f, 1f]), [Math.Sqrt(2f), 0f], SameVector);
    }
}
