namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class TransformDiscreteFourierV1Block
    {
        internal const string Identity = "transform.discrete-fourier@1";
        internal static MathBlockOperation Create() => CreateDft();
        private static MathBlockOperation CreateDft() => MathBlockOperationFactory.Create("transform.discrete-fourier", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.ComplexVector(types[0].Unit, types[0].Rows);
        }, inputs => inputs[0].AsVector().Count > 0 ? MathBlockValue.ComplexVector(MathBlockPath.DiscreteFourierTransform(inputs[0].AsVector()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.ComplexVector(inputs[0].Type.Unit), "The vector is empty."), [MathBlockValue.Vector([1d, 0d])], MathBlockValue.ComplexVector([new Complex(1d, 0d), new Complex(1d, 0d)]), 1e-9, 8);
    }
}
