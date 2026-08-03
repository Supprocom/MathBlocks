namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class ComplexVectorMagnitudeV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateComplexProjection("complex-vector.magnitude", MathBlockComplex.Magnitude, [Math.Sqrt(5d), 5d]);
    }
}
