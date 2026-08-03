namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarHyperbolicCosineV1Block
    {
        internal const string Identity = "scalar.hyperbolic-cosine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.hyperbolic-cosine", MathBlockScalar.HyperbolicCosine, 0d, 1d);
            return operations[0];
        }
    }
}
