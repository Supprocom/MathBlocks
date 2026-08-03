namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class ComplexVectorMagnitudeV1Block
    {
        internal const string Identity = "complex-vector.magnitude@1";
        internal static MathBlockOperation Create() => ComplexVectorMagnitudeV1BlockCpu.Create();
    }
}
