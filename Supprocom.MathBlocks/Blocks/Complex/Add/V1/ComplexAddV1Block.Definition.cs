namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexAddV1Block
    {
        internal const string Identity = "complex.add@1";
        internal static MathBlockOperation Create() => CreateBinary("complex.add", MathBlockComplex.Add, new(1d, 2d), new(3d, -1d), new(4d, 1d), SameComplex);
    }
}
