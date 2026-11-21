namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class SurvivalDiscreteHazardV1Block
    {
        internal const string Identity = "survival.discrete-hazard@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateDiscreteHazard();
        private static MathBlockOperation CreateDiscreteHazard() => MathBlockOperationFactory.Create("survival.discrete-hazard", 1, DimensionlessSameLengthVectorOutput, inputs => IsDistribution(inputs[0].AsVector()) ? MathBlockValue.Vector(MathBlockAdvanced.DiscreteHazard(inputs[0].AsVector()), default, true) : MathBlockOperationFactory.Invalid(DimensionlessSameLengthVectorOutput, inputs, "The vector is not a distribution."), [MathBlockValue.Vector([0.2f, 0.3f, 0.5f])], MathBlockValue.Vector([0.2f, 0.375f, 1f]), performanceIterations: 8);
    }
}
