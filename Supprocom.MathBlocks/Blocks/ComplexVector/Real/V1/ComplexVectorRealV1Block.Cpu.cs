namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class ComplexVectorRealV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateComplexProjection("complex-vector.real", value => value.Real, [1d, 3d]);
    }
}
