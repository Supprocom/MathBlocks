namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorLinspaceV1Block
    {
        internal const string Identity = "vector.linspace@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateLinspace();
        private static MathBlockOperation CreateLinspace() => MathBlockOperationFactory.CreateDomain("vector.linspace", 3, LinspaceType, (inputs, domain) =>
        {
            var count = RequirePositiveInteger(inputs[2].AsScalar());
            return count <= domain.Options.MaximumGeneratedVectorLength ? MathBlockValue.Vector(MathBlockVectorMath.Linspace(inputs[0].AsScalar(), inputs[1].AsScalar(), count), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The output length exceeds the operation limit.");
        }, [MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f), MathBlockValue.Scalar(3f)], MathBlockValue.Vector([0f, 0.5f, 1f]), performanceIterations: 32);
    }
}
