namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class ComplexVectorImaginaryV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateComplexProjection("complex-vector.imaginary", value => value.Imaginary, [2d, 4d]);
    }
}
