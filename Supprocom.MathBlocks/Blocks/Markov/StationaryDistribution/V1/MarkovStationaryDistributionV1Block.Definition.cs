namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MarkovStationaryDistributionV1Block
    {
        internal const string Identity = "markov.stationary-distribution@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateStationaryDistribution();
        private static MathBlockOperation CreateStationaryDistribution() => MathBlockOperationFactory.CreateDomain("markov.stationary-distribution", 2, MarkovVectorType, (inputs, domain) => IsTransitionMatrix(inputs[0].AsMatrix()) && TryInteger(inputs[1].AsScalar(), out var iterations) && iterations is > 0 && iterations <= domain.Options.MaximumIterationCount ? MathBlockValue.Vector(MathBlockAdvanced.StationaryDistribution(inputs[0].AsMatrix(), iterations), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(length: inputs[0].Type.Rows), "The inputs are outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.9f, 0.1f, 0.2f, 0.8f])), MathBlockValue.Scalar(128f)], MathBlockValue.Vector([2f / 3f, 1f / 3f]), 1e-8f, 2);
    }
}
