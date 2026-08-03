namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class TransformWalshHadamardV1Block
    {
        internal const string Identity = "transform.walsh-hadamard@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("transform.walsh-hadamard", MathBlockAdvanced.WalshHadamard, MathBlockValue.Vector([1d, 1d]), [Math.Sqrt(2d), 0d], SameVector);
    }
}
