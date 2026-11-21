namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class SurvivalProductLimitV1Block
    {
        internal const string Identity = "survival.product-limit@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreateProductLimit();
        private static MathBlockOperation CreateProductLimit() => MathBlockOperationFactory.Create("survival.product-limit", 2, ProductLimitType, inputs => AreProductLimitInputsValid(inputs[0].AsVector(), inputs[1].AsVector())
            ? MathBlockValue.Vector(
                MathBlockAdvanced.ProductLimitSurvival(inputs[0].AsVector(), inputs[1].AsVector()),
                default,
                true)
            : MathBlockOperationFactory.Invalid(ProductLimitType, inputs, "The vectors are outside the operation domain."),
            [MathBlockValue.Vector([1f, 1f]), MathBlockValue.Vector([4f, 3f])],
            MathBlockValue.Vector([0.75f, 0.5f]),
            performanceIterations: 8);

        private static MathBlockType ProductLimitType(IReadOnlyList<MathBlockType> types)
        {
            var vectors = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.Vector(length: vectors.Rows);
        }

        private static bool AreProductLimitInputsValid(
            Supprocom.MathBlocks.MathBlockVector events,
            Supprocom.MathBlocks.MathBlockVector atRisk)
        {
            if (events.Count != atRisk.Count)
                return false;
            for (var index = 0; index < events.Count; index++)
                if (events[index] < 0f || atRisk[index] <= 0f || events[index] > atRisk[index])
                    return false;
            return true;
        }
    }
}
