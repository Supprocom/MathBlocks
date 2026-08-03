namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarLessThanV1Block
    {
        internal const string Identity = "scalar.less-than@1";
        internal static MathBlockOperation Create() => ScalarLessThanV1BlockCpu.Create();
    }
}
