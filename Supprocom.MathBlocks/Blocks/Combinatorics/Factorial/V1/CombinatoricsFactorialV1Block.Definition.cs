namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class CombinatoricsFactorialV1Block
    {
        internal const string Identity = "combinatorics.factorial@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        /// <summary>Factorial of an integer from 0 to 34: in single precision 34! is the largest finite value and 35! is +infinity, which is invalid.</summary>
        internal static MathBlockOperation Create() => CreateIntegerUnary("combinatorics.factorial", MathBlockProbability.Factorial, 5, 120f);
        private static MathBlockOperation CreateIntegerUnary(string identifier, Func<int, float> function, int sample, float expected) => MathBlockOperationFactory.Create(identifier, 1, MathBlockTypeRules.DimensionlessScalar, inputs => TryInteger(inputs[0].AsScalar(), out var value) && value >= 0 && value <= 34 ? MathBlockValue.Scalar(function(value)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The input is not a supported integer."), [MathBlockValue.Scalar(sample)], MathBlockValue.Scalar(expected), performanceIterations: 128);
    }
}
