namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class CapacityChoquetIntegralV1Block
    {
        internal const string Identity = "capacity.choquet-integral@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateChoquet();
        private static MathBlockOperation CreateChoquet() => MathBlockOperationFactory.CreateDomain("capacity.choquet-integral", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Scalar(types[0].Unit);
        }, (inputs, domain) => inputs[0].AsVector().Count <= domain.Options.MaximumChoquetPlayerCount &&
                     inputs[1].AsVector().Count == 1 << inputs[0].AsVector().Count &&
                     MathBlockCollectionPrimitives.All(inputs[0].AsVector(), value => value >= 0f)
            ? MathBlockValue.Scalar(
                MathBlockAdvanced.ChoquetIntegral(inputs[0].AsVector(), inputs[1].AsVector()),
                inputs[0].Type.Unit)
            : MathBlockValue.Invalid(
                MathBlockType.Scalar(inputs[0].Type.Unit),
                "The inputs are outside the operation domain."),
            [MathBlockValue.Vector([1f, 2f]), MathBlockValue.Vector([0f, 0.4f, 0.6f, 1f])],
            MathBlockValue.Scalar(1.6f),
            performanceIterations: 4);
    }
}
