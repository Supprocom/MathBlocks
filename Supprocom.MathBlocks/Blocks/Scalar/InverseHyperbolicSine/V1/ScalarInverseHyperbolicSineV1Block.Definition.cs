namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarInverseHyperbolicSineV1Block
    {
        internal const string Identity = "scalar.inverse-hyperbolic-sine@1";
        internal static MathBlockOperation Create()
        {
            var operations = new List<MathBlockOperation>(1);
            AddDimensionlessUnary(operations, "scalar.inverse-hyperbolic-sine", MathBlockScalar.InverseHyperbolicSine, 0d, 0d);
            return operations[0];
        }
    }
}
