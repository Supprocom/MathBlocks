namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarCubeV1Block
    {
        internal const string Identity = "scalar.cube@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.cube", MathBlockScalar.Cube, 3d, 27d, MathBlockTypeRules.CubeScalar);
    }
}
