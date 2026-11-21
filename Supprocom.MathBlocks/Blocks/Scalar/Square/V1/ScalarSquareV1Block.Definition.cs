namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarSquareV1Block
    {
        internal const string Identity = "scalar.square@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.square", MathBlockScalar.Square, 4f, 16f, MathBlockTypeRules.SquareScalar);
    }
}
