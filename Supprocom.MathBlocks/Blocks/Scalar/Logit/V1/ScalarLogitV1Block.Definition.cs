namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarLogitV1Block
    {
        internal const string Identity = "scalar.logit@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.logit", MathBlockScalar.Logit, 0.5d, 0d);
            return operations[0];
        }
    }
}
