namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixStackRowsV1Block
    {
        internal const string Identity = "matrix.stack-rows@1";
        internal static MathBlockOperation Create() => CreateStackRows();
        private static MathBlockOperation CreateStackRows() => MathBlockOperationFactory.Create("matrix.stack-rows", 2, types =>
        {
            var vectorType = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.Matrix(vectorType.Unit, 2, vectorType.Rows);
        }, inputs => MathBlockValue.Matrix(MathBlockStructure.StackRows(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit), [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([3d, 4d])], matrix, performanceIterations: 16);
    }
}
