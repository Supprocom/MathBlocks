namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationConditionalMutualInformationV1Block
    {
        internal const string Identity = "information.conditional-mutual-information@1";
        internal static MathBlockOperation Create() => CreateConditionalMutualInformation();
        private static MathBlockOperation CreateConditionalMutualInformation()
        {
            var joint = MathBlockValue.Vector([0.25d, 0.25d, 0.25d, 0.25d]);
            return MathBlockOperationFactory.Create("information.conditional-mutual-information", 4, types =>
            {
                MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
                MathBlockTypeRules.RequireDimensionless(types[0]);
                for (var index = 1; index < 4; index++)
                {
                    MathBlockTypeRules.RequireKind(types[index], MathBlockValueKind.Scalar);
                    MathBlockTypeRules.RequireDimensionless(types[index]);
                }

                return MathBlockType.Scalar();
            }, inputs =>
            {
                var values = inputs[0].AsVector();
                if (!TryInteger(inputs[1].AsScalar(), out var firstCount) || firstCount <= 0 || !TryInteger(inputs[2].AsScalar(), out var secondCount) || secondCount <= 0 || !TryInteger(inputs[3].AsScalar(), out var conditionCount) || conditionCount <= 0 || (long)firstCount * secondCount * conditionCount != values.Count || !IsDistribution(values))
                {
                    return MathBlockValue.Invalid(MathBlockType.Scalar(), "The joint distribution shape is invalid.");
                }

                return MathBlockValue.Scalar(MathBlockProbability.ConditionalMutualInformation(values, firstCount, secondCount, conditionCount));
            }, [joint, MathBlockValue.Scalar(2d), MathBlockValue.Scalar(2d), MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(0d), performanceIterations: 8);
        }
    }
}
