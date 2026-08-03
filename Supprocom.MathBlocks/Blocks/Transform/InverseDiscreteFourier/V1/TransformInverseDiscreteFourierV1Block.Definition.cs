namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class TransformInverseDiscreteFourierV1Block
    {
        internal const string Identity = "transform.inverse-discrete-fourier@1";
        internal static MathBlockOperation Create() => CreateInverseDft();
        private static MathBlockOperation CreateInverseDft() => MathBlockOperationFactory.Create("transform.inverse-discrete-fourier", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.ComplexVector);
            return types[0];
        }, inputs => inputs[0].AsComplexVector().Count > 0 ? MathBlockValue.ComplexVector(MathBlockPath.InverseDiscreteFourierTransform(inputs[0].AsComplexVector()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.ComplexVector(inputs[0].Type.Unit), "The vector is empty."), [MathBlockValue.ComplexVector([new Complex(1d, 0d), new Complex(1d, 0d)])], MathBlockValue.ComplexVector([new Complex(1d, 0d), new Complex(0d, 0d)]), 1e-9, 8);
    }
}
