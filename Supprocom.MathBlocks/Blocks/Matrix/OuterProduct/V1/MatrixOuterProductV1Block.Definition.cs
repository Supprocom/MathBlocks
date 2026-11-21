namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixOuterProductV1Block
    {
        internal const string Identity = "matrix.outer-product@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateOuterProduct();
        private static MathBlockOperation CreateOuterProduct() => MathBlockOperationFactory.Create("matrix.outer-product", 2, OuterProductType, inputs => MathBlockValue.Matrix(MathBlockLinearAlgebra.OuterProduct(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit)), [MathBlockValue.Vector([1f, 2f]), MathBlockValue.Vector([3f, 4f])], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3f, 4f, 6f, 8f])), performanceIterations: 8);
    }
}
