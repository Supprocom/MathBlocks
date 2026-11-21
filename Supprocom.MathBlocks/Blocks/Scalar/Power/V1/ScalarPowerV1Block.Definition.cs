namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarPowerV1Block
    {
        internal const string Identity = "scalar.power@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.power", MathBlockScalar.Power, 2f, 3f, 8f, MathBlockTypeRules.DimensionlessBinaryScalar);
    }
}
