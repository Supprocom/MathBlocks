namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarNegateV1Block
    {
        internal const string Identity = "scalar.negate@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.negate", MathBlockScalar.Negate, 3d, -3d);
    }
}
