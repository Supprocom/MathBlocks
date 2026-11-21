namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarMinimumV1Block
    {
        internal const string Identity = "scalar.minimum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.minimum", MathBlockScalar.Minimum, 2f, 3f, 2f, MathBlockTypeRules.SameBinaryScalar);
    }
}
