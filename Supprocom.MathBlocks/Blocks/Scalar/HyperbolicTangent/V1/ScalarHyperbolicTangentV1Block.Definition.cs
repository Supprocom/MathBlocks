namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarHyperbolicTangentV1Block
    {
        internal const string Identity = "scalar.hyperbolic-tangent@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.hyperbolic-tangent", MathBlockScalar.HyperbolicTangent, 0d, 0d);
            return operations[0];
        }
    }
}
