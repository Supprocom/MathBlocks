namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class PolynomialDerivativeV1Block
    {
        internal const string Identity = "polynomial.derivative@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreatePolynomialDerivative();
        private static MathBlockOperation CreatePolynomialDerivative() => MathBlockOperationFactory.Create("polynomial.derivative", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Vector(length: types[0].Rows > 1 ? types[0].Rows - 1 : 1);
        }, inputs => MathBlockValue.Vector(MathBlockPolynomial.Derivative(inputs[0].AsVector()), default, true), [MathBlockValue.Vector([1f, 2f, 3f])], MathBlockValue.Vector([2f, 6f]), performanceIterations: 32);
    }
}
