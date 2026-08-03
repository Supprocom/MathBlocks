namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarPositivePartV1Block
    {
        internal const string Identity = "scalar.positive-part@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.positive-part", MathBlockScalar.PositivePart, -3d, 0d);
    }
}
