namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class CombinatoricsNonemptySubsetSumsV1Block
    {
        internal const string Identity = "combinatorics.nonempty-subset-sums@1";
        internal static MathBlockOperation Create() => CreateSubsetSums();
        private static MathBlockOperation CreateSubsetSums() => MathBlockOperationFactory.Create("combinatorics.nonempty-subset-sums", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Vector(types[0].Unit);
        }, inputs =>
        {
            var values = inputs[0].AsVector();
            return values.Count <= 20 ? MathBlockValue.Vector(MathBlockProbability.NonemptySubsetSums(values), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The vector is too large for explicit subset enumeration.");
        }, [MathBlockValue.Vector([1d, 2d])], MathBlockValue.Vector([1d, 2d, 3d]), performanceIterations: 4);
    }
}
