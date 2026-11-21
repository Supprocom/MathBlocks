namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarBinaryLogarithmV1Block
    {
        internal const string Identity = "scalar.binary-logarithm@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.binary-logarithm", MathBlockScalar.BinaryLogarithm, 8f, 3f);
            return operations[0];
        }
    }
}
