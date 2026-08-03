namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarAddV1Block
    {
        internal const string Identity = "scalar.add@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.add", MathBlockScalar.Add, 2d, 3d, 5d, MathBlockTypeRules.SameBinaryScalar);
    }
}
