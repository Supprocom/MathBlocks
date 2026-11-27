namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarHyperbolicCosineV1Block
    {
        internal const string Identity = "scalar.hyperbolic-cosine@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        /// <summary>Hyperbolic cosine. Finite up to |x| of about 89.415; beyond that the result overflows and the row is invalid.</summary>
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.hyperbolic-cosine", MathBlockScalar.HyperbolicCosine, 0f, 1f);
            return operations[0];
        }
    }
}
