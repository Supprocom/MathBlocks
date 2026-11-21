namespace Supprocom.MathBlocks;

internal static partial class ComplexMathBlocks
{
    internal static class ComplexCreateV1Block
    {
        internal const string Identity = "complex.create@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("complex.create", 2, ResolveCreate, inputs => MathBlockValue.Complex(MathBlockComplex.Create(inputs[0].AsScalar(), inputs[1].AsScalar()), inputs[0].Type.Unit), [MathBlockValue.Scalar(2f), MathBlockValue.Scalar(-3f)], MathBlockValue.Complex(new Complex(2f, -3f)), performanceIterations: 256);
    }
}
