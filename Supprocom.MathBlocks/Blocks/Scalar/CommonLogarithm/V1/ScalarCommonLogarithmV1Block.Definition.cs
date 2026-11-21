namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarCommonLogarithmV1Block
    {
        internal const string Identity = "scalar.common-logarithm@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.common-logarithm", MathBlockScalar.CommonLogarithm, 100f, 2f);
            return operations[0];
        }
    }
}
