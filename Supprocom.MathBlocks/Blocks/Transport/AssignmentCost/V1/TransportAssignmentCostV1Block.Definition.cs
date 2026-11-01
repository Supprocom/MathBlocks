namespace Supprocom.MathBlocks;

internal static partial class TransportMathBlocks
{
    internal static class TransportAssignmentCostV1Block
    {
        internal const string Identity = "transport.assignment-cost@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateAssignmentCost();
        private static MathBlockOperation CreateAssignmentCost() => MathBlockOperationFactory.Create("transport.assignment-cost", 2, types =>
        {
            RequireSquareMatrix(types[0]);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            if (types[0].Rows != 0 && types[1].Rows != 0 && types[0].Rows != types[1].Rows)
                throw new InvalidOperationException("The matrix and assignment dimensions must agree.");
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs => IsAssignment(inputs[1].AsVector(), inputs[0].AsMatrix().Columns) ? MathBlockValue.Scalar(MathBlockTransport.AssignmentCost(inputs[0].AsMatrix(), inputs[1].AsVector()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "An assignment index is not a column index."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 1d, 1d, 3d])), MathBlockValue.Vector([1d, 0d])], MathBlockValue.Scalar(2d), performanceIterations: 8);

        // Each row's assignment is a column index: a non-negative integer below the column count.
        private static bool IsAssignment(MathBlockVector assignment, int columns)
        {
            for (var row = 0; row < assignment.Count; row++)
            {
                var value = assignment[row];
                if (value < 0d || value >= columns || value != Math.Truncate(value))
                    return false;
            }
            return true;
        }
    }
}
