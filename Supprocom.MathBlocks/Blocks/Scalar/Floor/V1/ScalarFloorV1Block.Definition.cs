namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarFloorV1Block
    {
        internal const string Identity = "scalar.floor@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.floor", MathBlockScalar.Floor, 2.75d, 2d);
    }
}
