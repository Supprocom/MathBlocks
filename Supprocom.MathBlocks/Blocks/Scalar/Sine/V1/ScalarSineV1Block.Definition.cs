namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarSineV1Block
    {
        internal const string Identity = "scalar.sine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.sine", MathBlockScalar.Sine, Math.PI / 2d, 1d);
            return operations[0];
        }
    }
}
