namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarInverseHyperbolicCosineV1Block
    {
        internal const string Identity = "scalar.inverse-hyperbolic-cosine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.inverse-hyperbolic-cosine", MathBlockScalar.InverseHyperbolicCosine, 1d, 0d);
            return operations[0];
        }
    }
}
