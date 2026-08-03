namespace Supprocom.MathBlocks;
internal static partial class ComplexMathBlocks
{
    internal static class ComplexFromPolarV1Block
    {
        internal const string Identity = "complex.from-polar@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("complex.from-polar", 2, ResolvePolar, inputs => MathBlockValue.Complex(MathBlockComplex.FromPolar(inputs[0].AsScalar(), inputs[1].AsScalar()), inputs[0].Type.Unit), [MathBlockValue.Scalar(2d), MathBlockValue.Scalar(Math.PI / 2d)], MathBlockValue.Complex(new Complex(0d, 2d)), 1e-9, 256);
    }
}
