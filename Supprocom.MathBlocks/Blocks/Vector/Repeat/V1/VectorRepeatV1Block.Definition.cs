namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorRepeatV1Block
    {
        internal const string Identity = "vector.repeat@1";
        internal static MathBlockOperation Create() => CreateRepeat();
        private static MathBlockOperation CreateRepeat() => MathBlockOperationFactory.Create("vector.repeat", 2, RepeatType, inputs =>
        {
            var count = RequireNonnegativeInteger(inputs[1].AsScalar());
            return count <= 1_000_000 ? MathBlockValue.Vector(MathBlockVectorMath.Repeat(inputs[0].AsScalar(), count), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The output length exceeds the operation limit.");
        }, [MathBlockValue.Scalar(2d), MathBlockValue.Scalar(3d)], MathBlockValue.Vector([2d, 2d, 2d]), performanceIterations: 32);
    }
}
