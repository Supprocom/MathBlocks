namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class SpecialErrorFunctionV1Block
    {
        internal const string Identity = "special.error-function@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "special.error-function", MathBlockScalar.ErrorFunction, 0f, 0f);
            return operations[0];
        }
    }
}
