namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportMinimumAssignmentV1Block
    {
        internal const string Identity = "transport.minimum-assignment@1";
        internal static MathBlockOperation Create() => CreateMinimumAssignment();
        private static MathBlockOperation CreateMinimumAssignment() => MathBlockOperationFactory.Create("transport.minimum-assignment", 1, types =>
        {
            RequireSquareMatrix(types[0]);
            return MathBlockType.Vector(length: types[0].Rows);
        }, inputs => inputs[0].AsMatrix().Rows <= 20 ? MathBlockValue.Vector(MathBlockTransport.MinimumAssignment(inputs[0].AsMatrix()), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(), "The matrix is too large for exact assignment."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 1d, 1d, 3d]))], MathBlockValue.Vector([1d, 0d]), performanceIterations: 2);
    }
}
