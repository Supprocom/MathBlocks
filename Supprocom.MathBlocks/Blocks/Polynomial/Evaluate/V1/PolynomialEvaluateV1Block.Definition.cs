namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class PolynomialEvaluateV1Block
    {
        internal const string Identity = "polynomial.evaluate@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreatePolynomialEvaluate();
        private static MathBlockOperation CreatePolynomialEvaluate() => MathBlockOperationFactory.Create("polynomial.evaluate", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Scalar();
        }, inputs => MathBlockValue.Scalar(MathBlockPolynomial.Evaluate(inputs[0].AsVector(), inputs[1].AsScalar())), [MathBlockValue.Vector([1f, 2f, 3f]), MathBlockValue.Scalar(2f)], MathBlockValue.Scalar(17f), performanceIterations: 32);
    }
}
