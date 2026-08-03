namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarModuloV1Block
    {
        internal const string Identity = "scalar.modulo@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("scalar.modulo", MathBlockScalar.Modulo, 7d, 3d, 1d, MathBlockTypeRules.SameBinaryScalar);
    }
}
