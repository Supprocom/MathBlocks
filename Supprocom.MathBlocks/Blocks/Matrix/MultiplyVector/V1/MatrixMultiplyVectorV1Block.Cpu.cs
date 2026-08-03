namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixMultiplyVectorV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateMatrixVector();
        private static MathBlockOperation CreateMatrixVector() => MathBlockOperationFactory.Create("matrix.multiply-vector", 2, MatrixVectorType, inputs => MathBlockValue.Vector(MathBlockLinearAlgebra.Multiply(inputs[0].AsMatrix(), inputs[1].AsVector()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit), true), [matrixA, MathBlockValue.Vector([1d, 2d])], MathBlockValue.Vector([5d, 11d]), performanceIterations: 8);
    }
}
