namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class CapacityChoquetIntegralV1Block
    {
        internal const string Identity = "capacity.choquet-integral@1";
        internal static MathBlockOperation Create() => CreateChoquet();
        private static MathBlockOperation CreateChoquet() => MathBlockOperationFactory.Create("capacity.choquet-integral", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs => inputs[0].AsVector().Count < 31 &&
                     inputs[1].AsVector().Count == 1 << inputs[0].AsVector().Count &&
                     MathBlockCollectionPrimitives.All(inputs[0].AsVector(), value => value >= 0d)
            ? MathBlockValue.Scalar(
                MathBlockAdvanced.ChoquetIntegral(inputs[0].AsVector(), inputs[1].AsVector()),
                inputs[0].Type.Unit)
            : MathBlockValue.Invalid(
                MathBlockType.Scalar(inputs[0].Type.Unit),
                "The inputs are outside the operation domain."),
            [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([0d, 0.4d, 0.6d, 1d])],
            MathBlockValue.Scalar(1.6d),
            performanceIterations: 4);
    }
}
