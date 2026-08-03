namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class PolynomialDerivativeV1Block
    {
        internal const string Identity = "polynomial.derivative@1";
        internal static MathBlockOperation Create() => CreatePolynomialDerivative();
        private static MathBlockOperation CreatePolynomialDerivative() => MathBlockOperationFactory.Create("polynomial.derivative", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Vector(length: types[0].Rows > 1 ? types[0].Rows - 1 : 1);
        }, inputs => MathBlockValue.Vector(MathBlockPolynomial.Derivative(inputs[0].AsVector()), default, true), [MathBlockValue.Vector([1d, 2d, 3d])], MathBlockValue.Vector([2d, 6d]), performanceIterations: 32);
    }
}
