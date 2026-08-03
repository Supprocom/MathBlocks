namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarMaximumV1Block
    {
        internal const string Identity = "scalar.maximum@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.maximum", MathBlockScalar.Maximum, 2d, 3d, 3d, MathBlockTypeRules.SameBinaryScalar);
    }
}
