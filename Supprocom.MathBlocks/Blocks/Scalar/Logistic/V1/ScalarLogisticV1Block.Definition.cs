namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarLogisticV1Block
    {
        internal const string Identity = "scalar.logistic@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.logistic", MathBlockScalar.Logistic, 0d, 0.5d);
            return operations[0];
        }
    }
}
