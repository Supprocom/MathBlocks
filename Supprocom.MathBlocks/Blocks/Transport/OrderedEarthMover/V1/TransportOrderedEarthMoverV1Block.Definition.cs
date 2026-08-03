namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportOrderedEarthMoverV1Block
    {
        internal const string Identity = "transport.ordered-earth-mover@1";
        internal static MathBlockOperation Create() => CreateOrderedEarthMover();
        private static MathBlockOperation CreateOrderedEarthMover() => MathBlockOperationFactory.Create("transport.ordered-earth-mover", 2, types =>
        {
            MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Scalar();
        }, inputs => IsDistribution(inputs[0].AsVector()) && IsDistribution(inputs[1].AsVector()) ? MathBlockValue.Scalar(MathBlockTransport.OrderedEarthMoverDistance(inputs[0].AsVector(), inputs[1].AsVector())) : MathBlockValue.Invalid(MathBlockType.Scalar(), "An input is not a distribution."), [MathBlockValue.Vector([1d, 0d]), MathBlockValue.Vector([0d, 1d])], MathBlockValue.Scalar(1d), performanceIterations: 8);
    }
}
