namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportUniformWassersteinV1Block
    {
        internal const string Identity = "transport.uniform-wasserstein@1";
        internal static MathBlockOperation Create() => CreateUniformWasserstein();
        private static MathBlockOperation CreateUniformWasserstein() => MathBlockOperationFactory.Create("transport.uniform-wasserstein", 3, types =>
        {
            SameSupportPair(types[0], types[1]);
            MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[2]);
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs =>
        {
            var order = inputs[2].AsScalar();
            return inputs[0].AsVector().Count > 0 && order >= 1d ? MathBlockValue.Scalar(MathBlockTransport.UniformWasserstein(inputs[0].AsVector(), inputs[1].AsVector(), order), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The inputs are outside the operation domain.");
        }, [left, right, MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(1d), performanceIterations: 8);
    }
}
