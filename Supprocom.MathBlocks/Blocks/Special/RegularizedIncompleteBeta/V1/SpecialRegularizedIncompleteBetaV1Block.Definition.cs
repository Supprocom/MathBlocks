namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class SpecialRegularizedIncompleteBetaV1Block
    {
        internal const string Identity = "special.regularized-incomplete-beta@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateIncompleteBeta();
        private static MathBlockOperation CreateIncompleteBeta() => MathBlockOperationFactory.CreateDomain("special.regularized-incomplete-beta", 3, types =>
        {
            foreach (var type in types)
            {
                MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Scalar);
                MathBlockTypeRules.RequireDimensionless(type);
            }

            return MathBlockType.Scalar();
        }, (inputs, domain) =>
        {
            var x = inputs[0].AsScalar();
            var left = inputs[1].AsScalar();
            var right = inputs[2].AsScalar();
            if (!(x is >= 0d and <= 1d && left > 0d && right > 0d))
                return MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the beta domain.");
            var options = domain.Options;
            var value = MathBlockProbability.RegularizedIncompleteBeta(x, left, right, options.IncompleteBetaMaximumIterations, options.IncompleteBetaTolerance, out var converged);
            if (converged)
                return MathBlockValue.Scalar(value);
            domain.RecordNonConvergence();
            return options.IncompleteBetaNonConvergence == MathBlockNonConvergencePolicy.Invalid
                ? MathBlockValue.Invalid(MathBlockType.Scalar(), "The continued fraction did not converge.")
                : MathBlockValue.Scalar(value);
        }, [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(0.5d), 1e-9, 32);
    }
}
