namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarModuloV1Block
    {
        internal const string Identity = "scalar.modulo@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.modulo", MathBlockScalar.Modulo, 7f, 3f, 1f, MathBlockTypeRules.SameBinaryScalar);
    }
}
