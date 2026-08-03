namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarArcCosineV1Block
    {
        internal const string Identity = "scalar.arc-cosine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.arc-cosine", MathBlockScalar.ArcCosine, -1d, Math.PI);
            return operations[0];
        }
    }
}
