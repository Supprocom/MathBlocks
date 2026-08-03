namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexCreateV1Block
    {
        internal const string Identity = "complex.create@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("complex.create", 2, ResolveCreate, inputs => MathBlockValue.Complex(MathBlockComplex.Create(inputs[0].AsScalar(), inputs[1].AsScalar()), inputs[0].Type.Unit), [MathBlockValue.Scalar(2d), MathBlockValue.Scalar(-3d)], MathBlockValue.Complex(new Complex(2d, -3d)), performanceIterations: 256);
    }
}
