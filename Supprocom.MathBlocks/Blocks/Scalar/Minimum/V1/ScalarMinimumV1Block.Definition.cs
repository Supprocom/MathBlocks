namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarMinimumV1Block
    {
        internal const string Identity = "scalar.minimum@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.minimum", MathBlockScalar.Minimum, 2d, 3d, 2d, MathBlockTypeRules.SameBinaryScalar);
    }
}
