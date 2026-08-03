namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarCosineV1Block
    {
        internal const string Identity = "scalar.cosine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.cosine", MathBlockScalar.Cosine, Math.PI, -1d);
            return operations[0];
        }
    }
}
