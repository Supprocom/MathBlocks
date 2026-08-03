namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class TropicalMaxPlusMultiplyV1Block
    {
        internal const string Identity = "tropical.max-plus-multiply@1";
        internal static MathBlockOperation Create() => CreateSemiringMultiply("tropical.max-plus-multiply", MathBlockAdvanced.MaxPlusMultiply, new MathBlockMatrix(2, 2, [9d, 10d, 11d, 12d]));
    }
}
