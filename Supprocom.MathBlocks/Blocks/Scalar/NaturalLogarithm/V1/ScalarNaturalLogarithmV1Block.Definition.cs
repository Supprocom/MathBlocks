namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarNaturalLogarithmV1Block
    {
        internal const string Identity = "scalar.natural-logarithm@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.natural-logarithm", MathBlockScalar.NaturalLogarithm, Math.E, 1d);
            return operations[0];
        }
    }
}
