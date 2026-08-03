namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorAllV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanReduction(
            "boolean-vector.all",
            values => MathBlockCollectionPrimitives.All(values, value => value),
            false);
    }
}
