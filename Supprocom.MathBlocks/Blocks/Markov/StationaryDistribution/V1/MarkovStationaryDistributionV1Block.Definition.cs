namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MarkovStationaryDistributionV1Block
    {
        internal const string Identity = "markov.stationary-distribution@1";
        internal static MathBlockOperation Create() => CreateStationaryDistribution();
        private static MathBlockOperation CreateStationaryDistribution() => MathBlockOperationFactory.Create("markov.stationary-distribution", 2, MarkovVectorType, inputs => IsTransitionMatrix(inputs[0].AsMatrix()) && TryInteger(inputs[1].AsScalar(), out var iterations) && iterations > 0 ? MathBlockValue.Vector(MathBlockAdvanced.StationaryDistribution(inputs[0].AsMatrix(), iterations), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(length: inputs[0].Type.Rows), "The inputs are outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.9d, 0.1d, 0.2d, 0.8d])), MathBlockValue.Scalar(128d)], MathBlockValue.Vector([2d / 3d, 1d / 3d]), 1e-8, 2);
    }
}
