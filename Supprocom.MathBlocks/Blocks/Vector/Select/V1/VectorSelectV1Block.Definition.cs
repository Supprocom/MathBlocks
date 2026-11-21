namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorSelectV1Block
    {
        internal const string Identity = "vector.select@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateVectorSelect();
        private static MathBlockOperation CreateVectorSelect() => MathBlockOperationFactory.Create("vector.select", 3, VectorSelectType, inputs => inputs[0].AsBooleanVector().Count == inputs[1].AsVector().Count && inputs[1].AsVector().Count == inputs[2].AsVector().Count ? MathBlockValue.Vector(MathBlockVectorMath.Select(inputs[0].AsBooleanVector(), inputs[1].AsVector(), inputs[2].AsVector()), inputs[1].Type.Unit, true) : MathBlockOperationFactory.Invalid(VectorSelectType, inputs, "The input row counts must be equal."), [MathBlockValue.BooleanVector([true, false]), MathBlockValue.Vector([1f, 2f]), MathBlockValue.Vector([3f, 4f])], MathBlockValue.Vector([1f, 4f]), performanceIterations: 64);
    }
}
