namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class SurvivalDiscreteHazardV1Block
    {
        internal const string Identity = "survival.discrete-hazard@1";
        internal static MathBlockOperation Create() => CreateDiscreteHazard();
        private static MathBlockOperation CreateDiscreteHazard() => MathBlockOperationFactory.Create("survival.discrete-hazard", 1, DimensionlessSameLengthVectorOutput, inputs => IsDistribution(inputs[0].AsVector()) ? MathBlockValue.Vector(MathBlockAdvanced.DiscreteHazard(inputs[0].AsVector()), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(), "The vector is not a distribution."), [MathBlockValue.Vector([0.2d, 0.3d, 0.5d])], MathBlockValue.Vector([0.2d, 0.375d, 1d]), performanceIterations: 8);
    }
}
