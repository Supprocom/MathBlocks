namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class CapacityMobiusTransformV1Block
    {
        internal const string Identity = "capacity.mobius-transform@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateSetFunctionVector("capacity.mobius-transform", MathBlockAdvanced.MobiusTransform, [0f, 0.4f, 0.6f, 0f]);
        private static MathBlockOperation CreateSetFunctionVector(string identifier, Func<IReadOnlyList<float>, float[]> function, float[] expected) => MathBlockOperationFactory.Create(identifier, 1, SameVector, inputs => IsPowerOfTwo(inputs[0].AsVector().Count) ? MathBlockValue.Vector(function(inputs[0].AsVector()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(inputs[0].Type, "The set-function length is invalid."), [MathBlockValue.Vector([0f, 0.4f, 0.6f, 1f])], MathBlockValue.Vector(expected), performanceIterations: 4);
    }
}
