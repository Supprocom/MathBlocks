namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorAnyV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanReduction(
            "boolean-vector.any",
            values => MathBlockCollectionPrimitives.Any(values, value => value),
            true);
    }
}
