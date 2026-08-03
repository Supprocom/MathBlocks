namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class CombinatoricsBallotCountV1Block
    {
        internal const string Identity = "combinatorics.ballot-count@1";
        internal static MathBlockOperation Create() => CreateBallotCount();
        private static MathBlockOperation CreateBallotCount() => MathBlockOperationFactory.Create("combinatorics.ballot-count", 2, MathBlockTypeRules.DimensionlessBinaryScalar, inputs => TryInteger(inputs[0].AsScalar(), out var leading) && TryInteger(inputs[1].AsScalar(), out var trailing) && leading > trailing && trailing >= 0 ? MathBlockValue.Scalar(MathBlockAdvanced.BallotCount(leading, trailing)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The counts are outside the ballot domain."), [MathBlockValue.Scalar(3d), MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(2d), performanceIterations: 16);
    }
}
