namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class PointSetFromMatrixV1Block
    {
        internal const string Identity = "point-set.from-matrix@1";
        internal static MathBlockOperation Create() => CreatePointSetFromMatrix();
        private static MathBlockOperation CreatePointSetFromMatrix() => MathBlockOperationFactory.Create("point-set.from-matrix", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            if (types[0].Columns is not 0 and not 2)
                throw new InvalidOperationException("The matrix must have two columns.");
            return MathBlockType.PointSet(types[0].Unit, types[0].Rows);
        }, inputs => inputs[0].AsMatrix().Columns == 2 ? MathBlockValue.PointSet(MathBlockStructure.PointSetFromMatrix(inputs[0].AsMatrix()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.PointSet(inputs[0].Type.Unit), "The matrix must have two columns."), [matrix], MathBlockValue.PointSet(new MathBlockPointSet([new(1d, 2d), new(3d, 4d)])), performanceIterations: 16);
    }
}
