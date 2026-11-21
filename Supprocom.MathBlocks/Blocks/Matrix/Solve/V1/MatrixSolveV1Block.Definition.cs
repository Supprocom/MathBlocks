namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixSolveV1Block
    {
        internal const string Identity = "matrix.solve@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateSolve();
        private static MathBlockOperation CreateSolve() => MathBlockOperationFactory.Create("matrix.solve", 2, SolveType, inputs => MathBlockLinearAlgebra.TrySolve(inputs[0].AsMatrix(), inputs[1].AsVector(), out var solution) ? MathBlockValue.Vector(solution, inputs[1].Type.Unit.Divide(inputs[0].Type.Unit), true) : MathBlockOperationFactory.Invalid(SolveType, inputs, "The matrix is singular."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2f, 0f, 0f, 4f])), MathBlockValue.Vector([4f, 8f])], MathBlockValue.Vector([2f, 2f]), performanceIterations: 8);
    }
}
