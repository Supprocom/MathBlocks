namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarSoftplusV1Block
    {
        internal const string Identity = "scalar.softplus@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.softplus", MathBlockScalar.Softplus, 0f, Math.Log(2f));
            return operations[0];
        }
    }
}
