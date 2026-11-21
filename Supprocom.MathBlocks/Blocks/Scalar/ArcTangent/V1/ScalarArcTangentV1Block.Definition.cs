namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarArcTangentV1Block
    {
        internal const string Identity = "scalar.arc-tangent@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.arc-tangent", MathBlockScalar.ArcTangent, 1f, Math.PI / 4f);
            return operations[0];
        }
    }
}
