namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportWeightedWasserstein1V1Block
    {
        internal const string Identity = "transport.weighted-wasserstein-1@1";
        internal static MathBlockOperation Create() => CreateWeightedWasserstein();
        private static MathBlockOperation CreateWeightedWasserstein() => MathBlockOperationFactory.Create("transport.weighted-wasserstein-1", 4, types =>
        {
            SameSupportPair(types[0], types[2]);
            RequireWeights(types[1], types[0]);
            RequireWeights(types[3], types[2]);
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs => IsDistribution(inputs[1].AsVector()) && IsDistribution(inputs[3].AsVector()) ? MathBlockValue.Scalar(MathBlockTransport.WeightedWasserstein1(inputs[0].AsVector(), inputs[1].AsVector(), inputs[2].AsVector(), inputs[3].AsVector()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "A weight vector is not a distribution."), [left, fair, right, fair], MathBlockValue.Scalar(1d), performanceIterations: 8);
    }
}
