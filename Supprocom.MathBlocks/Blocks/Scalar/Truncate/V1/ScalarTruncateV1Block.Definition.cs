namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarTruncateV1Block
    {
        internal const string Identity = "scalar.truncate@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.truncate", MathBlockScalar.Truncate, -2.75d, -2d);
    }
}
