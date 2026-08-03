namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSelectV1Block
    {
        internal const string Identity = "vector.select@1";
        internal static MathBlockOperation Create() => CreateVectorSelect();
        private static MathBlockOperation CreateVectorSelect() => MathBlockOperationFactory.Create("vector.select", 3, VectorSelectType, inputs => MathBlockValue.Vector(MathBlockVectorMath.Select(inputs[0].AsBooleanVector(), inputs[1].AsVector(), inputs[2].AsVector()), inputs[1].Type.Unit, true), [MathBlockValue.BooleanVector([true, false ]), MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([3d, 4d])], MathBlockValue.Vector([1d, 4d]), performanceIterations: 64);
    }
}
