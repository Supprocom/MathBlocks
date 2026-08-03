namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixCommutatorV1Block
    {
        internal const string Identity = "matrix.commutator@1";
        internal static MathBlockOperation Create() => CreateCommutator();
        private static MathBlockOperation CreateCommutator()
        {
            var left = MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 1d, 0d, 0d]));
            var right = MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 0d, 1d, 0d]));
            return MathBlockOperationFactory.Create("matrix.commutator", 2, ProductSquareMatrices, inputs => MathBlockValue.Matrix(MathBlockAdvanced.MatrixCommutator(inputs[0].AsMatrix(), inputs[1].AsMatrix()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit)), [left, right], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 0d, 0d, -1d])), performanceIterations: 8);
        }
    }
}
