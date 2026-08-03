namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarExponentialV1Block
    {
        internal const string Identity = "scalar.exponential@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.exponential", MathBlockScalar.Exponential, 1d, Math.E);
            return operations[0];
        }
    }
}
