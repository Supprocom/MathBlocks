namespace Supprocom.MathBlocks;

internal static partial class StructuralMathBlocks
{
    internal static class MatrixStackRowsV1Block
    {
        internal const string Identity = "matrix.stack-rows@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateStackRows();
        private static MathBlockOperation CreateStackRows() => MathBlockOperationFactory.Create("matrix.stack-rows", 2, StackRowsType, inputs => inputs[0].AsVector().Count == inputs[1].AsVector().Count ? MathBlockValue.Matrix(MathBlockStructure.StackRows(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit) : MathBlockOperationFactory.Invalid(StackRowsType, inputs, "The input row counts must be equal."), [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([3d, 4d])], matrix, performanceIterations: 16);

        private static MathBlockType StackRowsType(IReadOnlyList<MathBlockType> types)
        {
            var vectorType = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.Matrix(vectorType.Unit, 2, vectorType.Rows);
        }
    }
}
