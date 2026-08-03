namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarArcSineV1Block
    {
        internal const string Identity = "scalar.arc-sine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.arc-sine", MathBlockScalar.ArcSine, 1d, Math.PI / 2d);
            return operations[0];
        }
    }
}
