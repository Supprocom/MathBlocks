namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class PointSetToMatrixV1Block
    {
        internal const string Identity = "point-set.to-matrix@1";
        internal static MathBlockOperation Create() => CreatePointSetToMatrix();
        private static MathBlockOperation CreatePointSetToMatrix() => MathBlockOperationFactory.Create("point-set.to-matrix", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            return MathBlockType.Matrix(types[0].Unit, types[0].Rows, 2);
        }, inputs => inputs[0].AsPointSet().Count > 0 ? MathBlockValue.Matrix(MathBlockStructure.PointSetToMatrix(inputs[0].AsPointSet()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit, columns: 2), "The point set is empty."), [MathBlockValue.PointSet(new MathBlockPointSet([new(1d, 2d), new(3d, 4d)]))], matrix, performanceIterations: 16);
    }
}
