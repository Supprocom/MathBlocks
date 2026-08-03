namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexPhaseV1Block
    {
        internal const string Identity = "complex.phase@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("complex.phase", 1, ComplexPhaseType, inputs => MathBlockValue.Scalar(MathBlockComplex.Phase(inputs[0].AsComplex())), [MathBlockValue.Complex(new Complex(0d, 1d))], MathBlockValue.Scalar(Math.PI / 2d), performanceIterations: 256);
    }
}
