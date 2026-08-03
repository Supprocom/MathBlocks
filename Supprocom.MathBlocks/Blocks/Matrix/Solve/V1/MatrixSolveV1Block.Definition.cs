namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixSolveV1Block
    {
        internal const string Identity = "matrix.solve@1";
        internal static MathBlockOperation Create() => CreateSolve();
        private static MathBlockOperation CreateSolve() => MathBlockOperationFactory.Create("matrix.solve", 2, SolveType, inputs => MathBlockLinearAlgebra.TrySolve(inputs[0].AsMatrix(), inputs[1].AsVector(), out var solution) ? MathBlockValue.Vector(solution, inputs[1].Type.Unit.Divide(inputs[0].Type.Unit), true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[1].Type.Unit.Divide(inputs[0].Type.Unit)), "The matrix is singular."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2d, 0d, 0d, 4d])), MathBlockValue.Vector([4d, 8d])], MathBlockValue.Vector([2d, 2d]), performanceIterations: 8);
    }
}
