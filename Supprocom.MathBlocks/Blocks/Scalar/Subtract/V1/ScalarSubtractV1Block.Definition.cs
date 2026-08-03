namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarSubtractV1Block
    {
        internal const string Identity = "scalar.subtract@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.subtract", MathBlockScalar.Subtract, 7d, 2d, 5d, MathBlockTypeRules.SameBinaryScalar);
    }
}
