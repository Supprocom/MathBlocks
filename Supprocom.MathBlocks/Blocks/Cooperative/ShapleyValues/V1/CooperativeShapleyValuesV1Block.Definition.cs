namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class CooperativeShapleyValuesV1Block
    {
        internal const string Identity = "cooperative.shapley-values@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateShapley();
        private static MathBlockOperation CreateShapley() => MathBlockOperationFactory.CreateDomain("cooperative.shapley-values", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Vector(types[0].Unit);
        }, (inputs, domain) => IsPowerOfTwo(inputs[0].AsVector().Count) && inputs[0].AsVector().Count <= domain.Options.MaximumShapleyCoalitionValues ? MathBlockValue.Vector(MathBlockAdvanced.ShapleyValues(inputs[0].AsVector()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The coalition vector length is invalid."), [MathBlockValue.Vector([0f, 1f, 2f, 4f])], MathBlockValue.Vector([1.5f, 2.5f]), performanceIterations: 4);
    }
}
