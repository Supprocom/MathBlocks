namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarPowerV1Block
    {
        internal const string Identity = "scalar.power@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.power", MathBlockScalar.Power, 2d, 3d, 8d, MathBlockTypeRules.DimensionlessBinaryScalar);
    }
}
