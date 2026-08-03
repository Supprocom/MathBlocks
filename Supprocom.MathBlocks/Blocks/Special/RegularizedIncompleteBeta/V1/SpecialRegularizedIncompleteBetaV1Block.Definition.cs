namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class SpecialRegularizedIncompleteBetaV1Block
    {
        internal const string Identity = "special.regularized-incomplete-beta@1";
        internal static MathBlockOperation Create() => CreateIncompleteBeta();
        private static MathBlockOperation CreateIncompleteBeta() => MathBlockOperationFactory.Create("special.regularized-incomplete-beta", 3, types =>
        {
            foreach (var type in types)
            {
                MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Scalar);
                MathBlockTypeRules.RequireDimensionless(type);
            }

            return MathBlockType.Scalar();
        }, inputs =>
        {
            var x = inputs[0].AsScalar();
            var left = inputs[1].AsScalar();
            var right = inputs[2].AsScalar();
            return x is >= 0d and <= 1d && left > 0d && right > 0d ? MathBlockValue.Scalar(MathBlockProbability.RegularizedIncompleteBeta(x, left, right)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the beta domain.");
        }, [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(0.5d), 1e-9, 32);
    }
}
