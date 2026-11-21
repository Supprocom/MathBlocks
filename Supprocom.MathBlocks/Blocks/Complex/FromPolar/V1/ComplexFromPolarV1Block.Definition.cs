namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexFromPolarV1Block
    {
        internal const string Identity = "complex.from-polar@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("complex.from-polar", 2, ResolvePolar, inputs => MathBlockValue.Complex(MathBlockComplex.FromPolar(inputs[0].AsScalar(), inputs[1].AsScalar()), inputs[0].Type.Unit), [MathBlockValue.Scalar(2f), MathBlockValue.Scalar(Math.PI / 2f)], MathBlockValue.Complex(new Complex(0f, 2f)), 1e-9f, 256);
    }
}
