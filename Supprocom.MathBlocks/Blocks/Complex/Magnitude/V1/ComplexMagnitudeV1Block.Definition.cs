namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexMagnitudeV1Block
    {
        internal const string Identity = "complex.magnitude@1";
        internal static MathBlockOperation Create() => ComplexMagnitudeV1BlockCpu.Create();
    }
}
