namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarArcTangent2V1Block
    {
        internal const string Identity = "scalar.arc-tangent-2@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.arc-tangent-2", MathBlockScalar.ArcTangent2, 1d, 1d, Math.PI / 4d, MathBlockTypeRules.DimensionlessBinaryScalar);
    }
}
