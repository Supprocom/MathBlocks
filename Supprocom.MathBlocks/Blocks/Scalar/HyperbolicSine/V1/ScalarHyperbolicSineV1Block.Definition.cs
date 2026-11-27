namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarHyperbolicSineV1Block
    {
        internal const string Identity = "scalar.hyperbolic-sine@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        /// <summary>Hyperbolic sine. Finite up to |x| of about 89.415; beyond that the result overflows and the row is invalid.</summary>
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.hyperbolic-sine", MathBlockScalar.HyperbolicSine, 0f, 0f);
            return operations[0];
        }
    }
}
