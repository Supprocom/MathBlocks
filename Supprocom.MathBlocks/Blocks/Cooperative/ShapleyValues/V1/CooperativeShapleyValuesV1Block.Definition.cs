namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class CooperativeShapleyValuesV1Block
    {
        internal const string Identity = "cooperative.shapley-values@1";
        internal static MathBlockOperation Create() => CreateShapley();
        private static MathBlockOperation CreateShapley() => MathBlockOperationFactory.Create("cooperative.shapley-values", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Vector(types[0].Unit);
        }, inputs => IsPowerOfTwo(inputs[0].AsVector().Count) && inputs[0].AsVector().Count <= 1 << 20 ? MathBlockValue.Vector(MathBlockAdvanced.ShapleyValues(inputs[0].AsVector()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The coalition vector length is invalid."), [MathBlockValue.Vector([0d, 1d, 2d, 4d])], MathBlockValue.Vector([1.5d, 2.5d]), performanceIterations: 4);
    }
}
