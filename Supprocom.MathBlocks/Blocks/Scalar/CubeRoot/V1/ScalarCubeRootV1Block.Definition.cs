namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarCubeRootV1Block
    {
        internal const string Identity = "scalar.cube-root@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.cube-root", MathBlockScalar.CubeRoot, -8d, -2d, MathBlockTypeRules.CubeRootScalar);
    }
}
