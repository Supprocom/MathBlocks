namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarMultiplyV1Block
    {
        internal const string Identity = "scalar.multiply@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.multiply", MathBlockScalar.Multiply, 2f, 3f, 6f, MathBlockTypeRules.ScalarProduct);
    }
}
