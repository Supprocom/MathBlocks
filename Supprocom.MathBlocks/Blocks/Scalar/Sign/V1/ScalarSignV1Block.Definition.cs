namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarSignV1Block
    {
        internal const string Identity = "scalar.sign@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.sign", MathBlockScalar.Sign, -3d, -1d, MathBlockTypeRules.DimensionlessScalarFromScalar);
    }
}
