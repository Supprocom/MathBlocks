namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorLinspaceV1Block
    {
        internal const string Identity = "vector.linspace@1";
        internal static MathBlockOperation Create() => CreateLinspace();
        private static MathBlockOperation CreateLinspace() => MathBlockOperationFactory.Create("vector.linspace", 3, LinspaceType, inputs =>
        {
            var count = RequirePositiveInteger(inputs[2].AsScalar());
            return count <= 1_000_000 ? MathBlockValue.Vector(MathBlockVectorMath.Linspace(inputs[0].AsScalar(), inputs[1].AsScalar(), count), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The output length exceeds the operation limit.");
        }, [MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(3d)], MathBlockValue.Vector([0d, 0.5d, 1d]), performanceIterations: 32);
    }
}
