namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarDivideV1Block
    {
        internal const string Identity = "scalar.divide@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.divide", MathBlockScalar.Divide, 8d, 2d, 4d, MathBlockTypeRules.ScalarQuotient);
    }
}
