namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorDotV1Block
    {
        internal const string Identity = "vector.dot@1";
        internal static MathBlockOperation Create() => CreateDot();
        private static MathBlockOperation CreateDot() => MathBlockOperationFactory.Create("vector.dot", 2, DotType, inputs => MathBlockValue.Scalar(MathBlockVectorMath.Dot(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit)), [sampleVector, secondVector], MathBlockValue.Scalar(20d), 1e-9, 64);
    }
}
