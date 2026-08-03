namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixIntegerPowerV1Block
    {
        internal const string Identity = "matrix.integer-power@1";
        internal static MathBlockOperation Create() => CreateMatrixPower();
        private static MathBlockOperation CreateMatrixPower() => MathBlockOperationFactory.Create("matrix.integer-power", 2, types =>
        {
            RequireSquareMatrix(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            RequireDimensionlessScalar(types[1]);
            return types[0];
        }, inputs => TryInteger(inputs[1].AsScalar(), out var exponent) && exponent >= 0 ? MathBlockValue.Matrix(MathBlockAdvanced.MatrixPower(inputs[0].AsMatrix(), exponent)) : MathBlockValue.Invalid(inputs[0].Type, "The exponent is not a nonnegative integer."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 1d, 0d, 1d])), MathBlockValue.Scalar(3d)], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 3d, 0d, 1d])), performanceIterations: 4);
    }
}
