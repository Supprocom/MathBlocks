namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarArcTangent2V1Block
    {
        internal const string Identity = "scalar.arc-tangent-2@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.arc-tangent-2", MathBlockScalar.ArcTangent2, 1f, 1f, Math.PI / 4f, MathBlockTypeRules.DimensionlessBinaryScalar);
    }
}
