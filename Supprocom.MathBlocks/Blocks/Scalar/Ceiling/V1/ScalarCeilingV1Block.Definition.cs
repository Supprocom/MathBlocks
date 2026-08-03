namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarCeilingV1Block
    {
        internal const string Identity = "scalar.ceiling@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.ceiling", MathBlockScalar.Ceiling, 2.25d, 3d);
    }
}
