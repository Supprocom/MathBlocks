namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class CapacityIsSubmodularV1Block
    {
        internal const string Identity = "capacity.is-submodular@1";
        internal static MathBlockOperation Create() => CreateSetFunctionBoolean("capacity.is-submodular", MathBlockAdvanced.IsSubmodular, true);
        private static MathBlockOperation CreateSetFunctionBoolean(string identifier, Func<IReadOnlyList<double>, bool> function, bool expected) => MathBlockOperationFactory.Create(identifier, 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Boolean;
        }, inputs => IsPowerOfTwo(inputs[0].AsVector().Count) && inputs[0].AsVector().Count <= 1 << 12 ? MathBlockValue.Boolean(function(inputs[0].AsVector())) : MathBlockValue.Invalid(MathBlockType.Boolean, "The set-function length is invalid."), [MathBlockValue.Vector([0d, 0.4d, 0.6d, 1d])], MathBlockValue.Boolean(expected), performanceIterations: 2);
    }
}
