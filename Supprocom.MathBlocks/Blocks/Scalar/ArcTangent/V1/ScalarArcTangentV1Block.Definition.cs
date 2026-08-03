namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarArcTangentV1Block
    {
        internal const string Identity = "scalar.arc-tangent@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.arc-tangent", MathBlockScalar.ArcTangent, 1d, Math.PI / 4d);
            return operations[0];
        }
    }
}
