namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class CapacityIsSubmodularV1Block
    {
        internal const string Identity = "capacity.is-submodular@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateSetFunctionBoolean("capacity.is-submodular", MathBlockAdvanced.IsSubmodular, true);
        private static MathBlockOperation CreateSetFunctionBoolean(string identifier, Func<IReadOnlyList<float>, bool> function, bool expected) => MathBlockOperationFactory.CreateDomain(identifier, 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Boolean;
        }, (inputs, domain) => IsPowerOfTwo(inputs[0].AsVector().Count) && inputs[0].AsVector().Count <= domain.Options.MaximumSubmodularSetFunctionValues ? MathBlockValue.Boolean(function(inputs[0].AsVector())) : MathBlockValue.Invalid(MathBlockType.Boolean, "The set-function length is invalid."), [MathBlockValue.Vector([0f, 0.4f, 0.6f, 1f])], MathBlockValue.Boolean(expected), performanceIterations: 2);
    }
}
