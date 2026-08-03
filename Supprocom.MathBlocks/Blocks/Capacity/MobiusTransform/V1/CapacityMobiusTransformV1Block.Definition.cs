namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class CapacityMobiusTransformV1Block
    {
        internal const string Identity = "capacity.mobius-transform@1";
        internal static MathBlockOperation Create() => CreateSetFunctionVector("capacity.mobius-transform", MathBlockAdvanced.MobiusTransform, [0d, 0.4d, 0.6d, 0d]);
        private static MathBlockOperation CreateSetFunctionVector(string identifier, Func<IReadOnlyList<double>, double[]> function, double[] expected) => MathBlockOperationFactory.Create(identifier, 1, SameVector, inputs => IsPowerOfTwo(inputs[0].AsVector().Count) ? MathBlockValue.Vector(function(inputs[0].AsVector()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The set-function length is invalid."), [MathBlockValue.Vector([0d, 0.4d, 0.6d, 1d])], MathBlockValue.Vector(expected), performanceIterations: 4);
    }
}
