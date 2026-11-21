namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarInverseHyperbolicTangentV1Block
    {
        internal const string Identity = "scalar.inverse-hyperbolic-tangent@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.inverse-hyperbolic-tangent", MathBlockScalar.InverseHyperbolicTangent, 0f, 0f);
            return operations[0];
        }
    }
}
