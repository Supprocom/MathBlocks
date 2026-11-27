namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarSineV1Block
    {
        internal const string Identity = "scalar.sine@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        // The domain is |x| <= 2^24 (MathBlockPrimitives.TrigonometricArgumentLimit); beyond it, and for NaN and the infinities, the result is NaN and the row is invalid.
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.sine", MathBlockScalar.Sine, Math.PI / 2f, 1f);
            return operations[0];
        }
    }
}
