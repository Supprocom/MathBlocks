namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarLogOnePlusV1Block
    {
        internal const string Identity = "scalar.log-one-plus@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.log-one-plus", MathBlockScalar.LogOnePlus, 1f, Math.Log(2f));
            return operations[0];
        }
    }
}
