namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class SurvivalProductLimitV1Block
    {
        internal const string Identity = "survival.product-limit@1";
        internal static MathBlockOperation Create() => CreateProductLimit();
        private static MathBlockOperation CreateProductLimit() => MathBlockOperationFactory.Create("survival.product-limit", 2, types =>
        {
            var vectors = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.Vector(length: vectors.Rows);
        }, inputs => AreProductLimitInputsValid(inputs[0].AsVector(), inputs[1].AsVector())
            ? MathBlockValue.Vector(
                MathBlockAdvanced.ProductLimitSurvival(inputs[0].AsVector(), inputs[1].AsVector()),
                default,
                true)
            : MathBlockValue.Invalid(MathBlockType.Vector(), "The vectors are outside the operation domain."),
            [MathBlockValue.Vector([1d, 1d]), MathBlockValue.Vector([4d, 3d])],
            MathBlockValue.Vector([0.75d, 0.5d]),
            performanceIterations: 8);

        private static bool AreProductLimitInputsValid(
            IReadOnlyList<double> events,
            IReadOnlyList<double> atRisk)
        {
            if (events.Count != atRisk.Count)
                return false;
            for (var index = 0; index < events.Count; index++)
                if (events[index] < 0d || atRisk[index] <= 0d || events[index] > atRisk[index])
                    return false;
            return true;
        }
    }
}
