namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class TropicalMinPlusMultiplyV1Block
    {
        internal const string Identity = "tropical.min-plus-multiply@1";
        internal static MathBlockOperation Create() => CreateSemiringMultiply("tropical.min-plus-multiply", MathBlockAdvanced.MinPlusMultiply, new MathBlockMatrix(2, 2, [6d, 7d, 8d, 9d]));
    }
}
