namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class PolynomialElementarySymmetricV1Block
    {
        internal const string Identity = "polynomial.elementary-symmetric@1";
        internal static MathBlockOperation Create() => CreateElementarySymmetric();
        private static MathBlockOperation CreateElementarySymmetric() => MathBlockOperationFactory.Create("polynomial.elementary-symmetric", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Scalar();
        }, inputs =>
        {
            var values = inputs[0].AsVector();
            return TryInteger(inputs[1].AsScalar(), out var order) && order >= 0 && order <= values.Count ? MathBlockValue.Scalar(MathBlockProbability.ElementarySymmetricPolynomial(values, order)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The order is outside the polynomial domain.");
        }, [MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Scalar(2d)], MathBlockValue.Scalar(11d), performanceIterations: 16);
    }
}
