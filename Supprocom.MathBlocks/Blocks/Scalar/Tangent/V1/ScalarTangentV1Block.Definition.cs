namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarTangentV1Block
    {
        internal const string Identity = "scalar.tangent@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.tangent", MathBlockScalar.Tangent, Math.PI / 4d, 1d);
            return operations[0];
        }
    }
}
