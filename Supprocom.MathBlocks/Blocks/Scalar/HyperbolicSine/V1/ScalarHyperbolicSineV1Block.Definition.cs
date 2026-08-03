namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarHyperbolicSineV1Block
    {
        internal const string Identity = "scalar.hyperbolic-sine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.hyperbolic-sine", MathBlockScalar.HyperbolicSine, 0d, 0d);
            return operations[0];
        }
    }
}
