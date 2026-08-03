namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarSquareRootV1Block
    {
        internal const string Identity = "scalar.square-root@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.square-root", MathBlockScalar.SquareRoot, 9d, 3d, MathBlockTypeRules.SquareRootScalar);
    }
}
