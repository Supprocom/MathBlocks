namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixPerronVectorV1Block
    {
        internal const string Identity = "matrix.perron-vector@1";
        internal static MathBlockOperation Create() => CreatePerronVector();
        private static MathBlockOperation CreatePerronVector() => MathBlockOperationFactory.Create("matrix.perron-vector", 2, PerronVectorType, inputs => IsNonnegative(inputs[0].AsMatrix()) && TryInteger(inputs[1].AsScalar(), out var iterations) && iterations > 0 ? MathBlockValue.Vector(MathBlockAdvanced.PerronVector(inputs[0].AsMatrix(), iterations), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(length: inputs[0].Type.Rows), "The inputs are outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 1d, 1d, 1d])), MathBlockValue.Scalar(32d)], MathBlockValue.Vector([0.5d, 0.5d]), performanceIterations: 2);
    }
}
