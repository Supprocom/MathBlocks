namespace Supprocom.MathBlocks;

internal static partial class TransportMathBlocks
{
    internal static class TransportMinimumAssignmentV1Block
    {
        internal const string Identity = "transport.minimum-assignment@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateMinimumAssignment();
        private static MathBlockOperation CreateMinimumAssignment() => MathBlockOperationFactory.CreateDomain("transport.minimum-assignment", 1, MinimumAssignmentType, (inputs, domain) => inputs[0].AsMatrix().Rows <= domain.Options.MaximumExplicitSubsetSize ? MathBlockValue.Vector(MathBlockTransport.MinimumAssignment(inputs[0].AsMatrix()), default, true) : MathBlockOperationFactory.Invalid(MinimumAssignmentType, inputs, "The matrix is too large for exact assignment."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 1d, 1d, 3d]))], MathBlockValue.Vector([1d, 0d]), performanceIterations: 2);

        private static MathBlockType MinimumAssignmentType(IReadOnlyList<MathBlockType> types)
        {
            RequireSquareMatrix(types[0]);
            return MathBlockType.Vector(length: types[0].Rows);
        }
    }
}
