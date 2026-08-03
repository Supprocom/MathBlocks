namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationMutualInformationV1Block
    {
        internal const string Identity = "information.mutual-information@1";
        internal static MathBlockOperation Create() => CreateMutualInformation();
        private static MathBlockOperation CreateMutualInformation()
        {
            var independent = new MathBlockMatrix(2, 2, [0.25d, 0.25d, 0.25d, 0.25d]);
            return MathBlockOperationFactory.Create("information.mutual-information", 1, types =>
            {
                MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
                MathBlockTypeRules.RequireDimensionless(types[0]);
                return MathBlockType.Scalar();
            }, inputs => IsDistribution(inputs[0].AsMatrix().ToArray()) ? MathBlockValue.Scalar(MathBlockProbability.MutualInformation(inputs[0].AsMatrix())) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The matrix is not a joint probability distribution."), [MathBlockValue.Matrix(independent)], MathBlockValue.Scalar(0d), performanceIterations: 16);
        }
    }
}
