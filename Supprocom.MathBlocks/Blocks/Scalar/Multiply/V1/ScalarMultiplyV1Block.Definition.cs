namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarMultiplyV1Block
    {
        internal const string Identity = "scalar.multiply@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.multiply", MathBlockScalar.Multiply, 2d, 3d, 6d, MathBlockTypeRules.ScalarProduct);
    }
}
