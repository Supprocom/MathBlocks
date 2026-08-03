namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class CombinatoricsFactorialV1Block
    {
        internal const string Identity = "combinatorics.factorial@1";
        internal static MathBlockOperation Create() => CreateIntegerUnary("combinatorics.factorial", MathBlockProbability.Factorial, 5, 120d);
        private static MathBlockOperation CreateIntegerUnary(string identifier, Func<int, double> function, int sample, double expected) => MathBlockOperationFactory.Create(identifier, 1, MathBlockTypeRules.DimensionlessScalar, inputs => TryInteger(inputs[0].AsScalar(), out var value) && value >= 0 && value <= 170 ? MathBlockValue.Scalar(function(value)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The input is not a supported integer."), [MathBlockValue.Scalar(sample)], MathBlockValue.Scalar(expected), performanceIterations: 128);
    }
}
