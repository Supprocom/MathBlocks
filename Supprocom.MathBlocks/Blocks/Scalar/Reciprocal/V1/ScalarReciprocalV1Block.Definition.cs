namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarReciprocalV1Block
    {
        internal const string Identity = "scalar.reciprocal@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.reciprocal", MathBlockScalar.Reciprocal, 4d, 0.25d, MathBlockTypeRules.ReciprocalScalar);
    }
}
