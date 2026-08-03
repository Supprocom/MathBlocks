namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class CombinatoricsBinomialCoefficientV1Block
    {
        internal const string Identity = "combinatorics.binomial-coefficient@1";
        internal static MathBlockOperation Create() => CreateIntegerBinary("combinatorics.binomial-coefficient", MathBlockProbability.BinomialCoefficient, 5, 2, 10d);
        private static MathBlockOperation CreateIntegerBinary(string identifier, Func<int, int, double> function, int left, int right, double expected) => MathBlockOperationFactory.Create(identifier, 2, MathBlockTypeRules.DimensionlessBinaryScalar, inputs => TryInteger(inputs[0].AsScalar(), out var first) && TryInteger(inputs[1].AsScalar(), out var second) && first >= 0 ? MathBlockValue.Scalar(function(first, second)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "An input is not a supported integer."), [MathBlockValue.Scalar(left), MathBlockValue.Scalar(right)], MathBlockValue.Scalar(expected), performanceIterations: 128);
    }
}
