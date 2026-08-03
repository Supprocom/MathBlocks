namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportEnergyDistanceV1Block
    {
        internal const string Identity = "transport.energy-distance@1";
        internal static MathBlockOperation Create() => CreateEnergyDistance();
        private static MathBlockOperation CreateEnergyDistance() => MathBlockOperationFactory.Create("transport.energy-distance", 2, types =>
        {
            SameSupportPair(types[0], types[1], requireEqualLength: false);
            return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(1, 2)));
        }, inputs => inputs[0].AsVector().Count > 0 && inputs[1].AsVector().Count > 0 ? MathBlockValue.Scalar(MathBlockTransport.EnergyDistance(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit.Pow(new MathRational(1, 2))) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit.Pow(new MathRational(1, 2))), "A sample is empty."), [MathBlockValue.Vector([0d]), MathBlockValue.Vector([1d])], MathBlockValue.Scalar(Math.Sqrt(2d)), performanceIterations: 4);
    }
}
