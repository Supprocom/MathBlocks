namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class PolynomialBernsteinEvaluateV1Block
    {
        internal const string Identity = "polynomial.bernstein-evaluate@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateBernstein();
        private static MathBlockOperation CreateBernstein() => MathBlockOperationFactory.Create("polynomial.bernstein-evaluate", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            RequireDimensionlessScalar(types[1]);
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs => inputs[0].AsVector().Count > 0 && inputs[1].AsScalar() is >= 0f and <= 1f ? MathBlockValue.Scalar(MathBlockAdvanced.BernsteinEvaluate(inputs[0].AsVector(), inputs[1].AsScalar()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The inputs are outside the operation domain."), [MathBlockValue.Vector([0f, 1f, 0f]), MathBlockValue.Scalar(0.5f)], MathBlockValue.Scalar(0.5f), performanceIterations: 8);
    }
}
