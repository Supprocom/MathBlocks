namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarSubtractV1Block
    {
        internal const string Identity = "scalar.subtract@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.subtract", MathBlockScalar.Subtract, 7f, 2f, 5f, MathBlockTypeRules.SameBinaryScalar);
    }
}
