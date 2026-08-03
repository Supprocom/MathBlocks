namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarBinaryLogarithmV1Block
    {
        internal const string Identity = "scalar.binary-logarithm@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.binary-logarithm", MathBlockScalar.BinaryLogarithm, 8d, 3d);
            return operations[0];
        }
    }
}
