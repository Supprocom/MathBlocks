namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexMagnitudeV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("complex.magnitude", 1, ComplexMagnitudeType, inputs => MathBlockValue.Scalar(MathBlockComplex.Magnitude(inputs[0].AsComplex()), inputs[0].Type.Unit), [MathBlockValue.Complex(new Complex(3f, 4f))], MathBlockValue.Scalar(5f), performanceIterations: 256);
    }
}
