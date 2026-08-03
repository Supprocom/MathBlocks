namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixReshapeV1Block
    {
        internal const string Identity = "matrix.reshape@1";
        internal static MathBlockOperation Create() => CreateReshape();
        private static MathBlockOperation CreateReshape() => MathBlockOperationFactory.Create("matrix.reshape", 3, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            RequireDimensionlessScalar(types[1]);
            RequireDimensionlessScalar(types[2]);
            return MathBlockType.Matrix(types[0].Unit);
        }, inputs => TryNonnegativeInteger(inputs[1].AsScalar(), out var rows) && TryNonnegativeInteger(inputs[2].AsScalar(), out var columns) && rows > 0 && columns > 0 && rows * (long)columns == inputs[0].AsVector().Count ? MathBlockValue.Matrix(MathBlockStructure.Reshape(inputs[0].AsVector(), rows, columns), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit), "The requested shape does not match the vector."), [vector, MathBlockValue.Scalar(2d), MathBlockValue.Scalar(2d)], matrix, performanceIterations: 16);
    }
}
