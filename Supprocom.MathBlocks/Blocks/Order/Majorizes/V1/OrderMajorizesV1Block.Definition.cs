namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class OrderMajorizesV1Block
    {
        internal const string Identity = "order.majorizes@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorPairBoolean("order.majorizes", MathBlockAdvanced.Majorizes, MathBlockValue.Vector([3f, 1f]), MathBlockValue.Vector([2f, 2f]), true);
        private static MathBlockOperation CreateVectorPairBoolean(string identifier, Func<IReadOnlyList<float>, IReadOnlyList<float>, bool> function, MathBlockValue left, MathBlockValue right, bool expected) => MathBlockOperationFactory.Create(identifier, 2, types =>
        {
            MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.Boolean;
        }, inputs => MathBlockValue.Boolean(function(inputs[0].AsVector(), inputs[1].AsVector())), [left, right], MathBlockValue.Boolean(expected), performanceIterations: 8);
    }
}
