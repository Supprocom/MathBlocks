namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarSquareV1Block
    {
        internal const string Identity = "scalar.square@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.square", MathBlockScalar.Square, 4d, 16d, MathBlockTypeRules.SquareScalar);
    }
}
