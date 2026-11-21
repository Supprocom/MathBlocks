namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class PolynomialElementarySymmetricV1Block
    {
        internal const string Identity = "polynomial.elementary-symmetric@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
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
        }, [MathBlockValue.Vector([1f, 2f, 3f]), MathBlockValue.Scalar(2f)], MathBlockValue.Scalar(11f), performanceIterations: 16);
    }
}
