namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixFlattenV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateFlatten();
        private static MathBlockOperation CreateFlatten() => MathBlockOperationFactory.Create("matrix.flatten", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            var length = types[0].Rows > 0 && types[0].Columns > 0 ? types[0].Rows * types[0].Columns : 0;
            return MathBlockType.Vector(types[0].Unit, length);
        }, inputs => MathBlockValue.Vector(inputs[0].AsMatrix().ToArray(), inputs[0].Type.Unit, true), [matrix], vector, performanceIterations: 32);
    }
}
