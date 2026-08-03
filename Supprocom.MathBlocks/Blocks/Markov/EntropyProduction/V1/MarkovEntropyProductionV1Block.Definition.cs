namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MarkovEntropyProductionV1Block
    {
        internal const string Identity = "markov.entropy-production@1";
        internal static MathBlockOperation Create() => CreateEntropyProduction();
        private static MathBlockOperation CreateEntropyProduction() => MathBlockOperationFactory.Create("markov.entropy-production", 2, types =>
        {
            RequireSquareMatrix(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            if (types[0].Rows != 0 && types[1].Rows != 0 && types[0].Rows != types[1].Rows)
                throw new InvalidOperationException("The matrix and distribution dimensions must agree.");
            return MathBlockType.Scalar();
        }, inputs => IsTransitionMatrix(inputs[0].AsMatrix()) && IsDistribution(inputs[1].AsVector()) ? MathBlockValue.Scalar(MathBlockAdvanced.EntropyProduction(inputs[0].AsMatrix(), inputs[1].AsVector())) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 1d, 1d, 0d])), MathBlockValue.Vector([0.5d, 0.5d])], MathBlockValue.Scalar(0d), performanceIterations: 4);
    }
}
