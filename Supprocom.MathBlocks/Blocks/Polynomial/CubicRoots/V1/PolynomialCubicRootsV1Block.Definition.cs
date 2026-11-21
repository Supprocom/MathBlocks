namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class PolynomialCubicRootsV1Block
    {
        internal const string Identity = "polynomial.cubic-roots@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateCubicRoots();
        private static MathBlockOperation CreateCubicRoots() => MathBlockOperationFactory.Create("polynomial.cubic-roots", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            if (types[0].Rows is not 0 and not 4)
                throw new InvalidOperationException("A cubic polynomial requires four coefficients.");
            return MathBlockType.ComplexVector(length: 3);
        }, inputs => inputs[0].AsVector().Count == 4 ? MathBlockValue.ComplexVector(MathBlockPolynomial.CubicRoots(inputs[0].AsVector()[0], inputs[0].AsVector()[1], inputs[0].AsVector()[2], inputs[0].AsVector()[3]), default, true) : MathBlockValue.Invalid(MathBlockType.ComplexVector(length: 3), "A cubic polynomial requires four coefficients."), [MathBlockValue.Vector([-6f, 11f, -6f, 1f])], MathBlockValue.ComplexVector([new Complex(3f, 0f), new Complex(1f, 0f), new Complex(2f, 0f)]), 1e-8f, 8);
    }
}
