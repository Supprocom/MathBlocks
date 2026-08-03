namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixOuterProductV1Block
    {
        internal const string Identity = "matrix.outer-product@1";
        internal static MathBlockOperation Create() => CreateOuterProduct();
        private static MathBlockOperation CreateOuterProduct() => MathBlockOperationFactory.Create("matrix.outer-product", 2, OuterProductType, inputs => MathBlockValue.Matrix(MathBlockLinearAlgebra.OuterProduct(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit)), [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([3d, 4d])], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 4d, 6d, 8d])), performanceIterations: 8);
    }
}
