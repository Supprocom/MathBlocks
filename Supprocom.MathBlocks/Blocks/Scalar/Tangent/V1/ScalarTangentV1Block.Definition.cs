namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarTangentV1Block
    {
        internal const string Identity = "scalar.tangent@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        // The domain is |x| <= 2^24 (MathBlockPrimitives.TrigonometricArgumentLimit); beyond it, and for NaN and the infinities, the result is NaN and the row is invalid.
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.tangent", MathBlockScalar.Tangent, Math.PI / 4f, 1f);
            return operations[0];
        }
    }
}
