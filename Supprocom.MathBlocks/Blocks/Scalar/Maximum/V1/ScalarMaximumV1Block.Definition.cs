namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarMaximumV1Block
    {
        internal const string Identity = "scalar.maximum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.maximum", MathBlockScalar.Maximum, 2f, 3f, 3f, MathBlockTypeRules.SameBinaryScalar);
    }
}
