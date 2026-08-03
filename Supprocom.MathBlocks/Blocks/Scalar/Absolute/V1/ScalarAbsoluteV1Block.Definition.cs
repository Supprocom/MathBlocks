namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarAbsoluteV1Block
    {
        internal const string Identity = "scalar.absolute@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.absolute", MathBlockScalar.Absolute, -3d, 3d);
    }
}
