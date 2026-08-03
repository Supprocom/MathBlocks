namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportCouplingCostV1Block
    {
        internal const string Identity = "transport.coupling-cost@1";
        internal static MathBlockOperation Create() => CreateCouplingCost();
        private static MathBlockOperation CreateCouplingCost() => MathBlockOperationFactory.Create("transport.coupling-cost", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Matrix);
            MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Scalar(types[1].Unit);
        }, inputs => MathBlockValue.Scalar(MathBlockTransport.CouplingCost(inputs[0].AsMatrix(), inputs[1].AsMatrix()), inputs[1].Type.Unit), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.5d, 0d, 0d, 0.5d])), MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 1d, 1d, 0d]))], MathBlockValue.Scalar(0d), performanceIterations: 8);
    }
}
