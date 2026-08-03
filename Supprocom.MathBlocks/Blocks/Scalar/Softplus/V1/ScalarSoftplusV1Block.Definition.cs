namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarSoftplusV1Block
    {
        internal const string Identity = "scalar.softplus@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.softplus", MathBlockScalar.Softplus, 0d, Math.Log(2d));
            return operations[0];
        }
    }
}
