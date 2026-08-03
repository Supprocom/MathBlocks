namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorLengthV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateLength();
        private static MathBlockOperation CreateLength() => MathBlockOperationFactory.Create("vector.length", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Scalar();
        }, inputs => MathBlockValue.Scalar(inputs[0].AsVector().Count), [sampleVector], MathBlockValue.Scalar(4d), performanceIterations: 128);
    }
}
