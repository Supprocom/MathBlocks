namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>combinatorics.ballot-count@1</c> operation contract.</summary>
public sealed class CombinatoricsBallotCountV1BlockTests
{
    /// <summary>Checks the <c>combinatorics.ballot-count@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("combinatorics.ballot-count@1");

    /// <summary>
    /// Checks that, wherever a + b does not wrap, BallotCount returns the bits of the 0.6.1 expression and the operation is valid
    /// exactly where that expression was in its domain and finite.
    /// </summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void MatchesTheReferenceWhereTheSumDoesNotWrap()
    {
        var operation = MathBlockCatalog.Standard.Get("combinatorics.ballot-count");
        var pairs = CombinatoricsCostGuardReference.Pairs(CombinatoricsCostGuardReference.Values);
        var disagreements = new List<string>();
        var validRows = 0;
        var overflowRows = 0;
        for (var index = 0; index < pairs.Length; index++)
        {
            var (leading, trailing) = pairs[index];
            if ((long)leading + trailing > int.MaxValue)
                continue;
            var reference = CombinatoricsCostGuardReference.TodayBallot(leading, trailing);
            if (BitConverter.DoubleToInt64Bits(MathBlockAdvanced.BallotCount(leading, trailing)) != BitConverter.DoubleToInt64Bits(reference))
                disagreements.Add($"bits ({leading}, {trailing})");
            MathBlockValue[] inputs = [MathBlockValue.Scalar(leading), MathBlockValue.Scalar(trailing)];
            var result = operation.Evaluate(inputs);
            var expectedValid = CombinatoricsCostGuardReference.InBallotDomain(leading, trailing) && double.IsFinite(reference);
            if (result.IsValid != expectedValid)
                disagreements.Add($"valid ({leading}, {trailing})");
            else if (expectedValid)
                validRows++;
            if (CombinatoricsCostGuardReference.InBallotDomain(leading, trailing) && double.IsPositiveInfinity(reference))
                overflowRows++;
        }

        Assert.True(disagreements.Count == 0, string.Join(", ", disagreements.Take(20)));
        Assert.True(validRows > 50, $"Only {validRows} rows were valid.");
        Assert.True(overflowRows > 50, $"Only {overflowRows} rows overflowed.");
    }

    /// <summary>
    /// Checks the rows whose sum a + b is above 2^31 - 1: BallotCount and the operation give the value of the 64-bit expression, which is
    /// the finite value near a - 1 for b = 1 and +Infinity, so invalid, where the coefficient overflows.
    /// </summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void WrappedSumsGiveTheSixtyFourBitValue()
    {
        var operation = MathBlockCatalog.Standard.Get("combinatorics.ballot-count");
        int[] leadings = [int.MaxValue, int.MaxValue - 1, 2_000_000_000, 1_500_000_000, 1_073_741_825, 1_073_741_824];
        int[] trailings = [0, 1, 2, 3, 10, 100, 599, 600, 601, 1000, 100_000, 147_483_648, 1_073_741_823];
        var wrapped = 0;
        var finite = 0;
        for (var first = 0; first < leadings.Length; first++)
        {
            for (var second = 0; second < trailings.Length; second++)
            {
                var (leading, trailing) = (leadings[first], trailings[second]);
                if ((long)leading + trailing <= int.MaxValue || !CombinatoricsCostGuardReference.InBallotDomain(leading, trailing))
                    continue;
                wrapped++;
                var actual = MathBlockAdvanced.BallotCount(leading, trailing);
                var reference = CombinatoricsCostGuardReference.WideBallot(leading, trailing);
                if (reference is { } expected)
                    Assert.Equal(BitConverter.DoubleToInt64Bits(expected), BitConverter.DoubleToInt64Bits(actual));
                else
                    Assert.True(double.IsPositiveInfinity(actual), $"BallotCount({leading}, {trailing}) = {actual}.");
                MathBlockValue[] inputs = [MathBlockValue.Scalar(leading), MathBlockValue.Scalar(trailing)];
            var result = operation.Evaluate(inputs);
                Assert.Equal(double.IsFinite(actual), result.IsValid);
                if (result.IsValid)
                    finite++;
            }
        }

        Assert.True(wrapped > 20 && finite > 5, $"{wrapped} wrapped rows, {finite} finite.");
        MathBlockValue[] sampleInputs = [MathBlockValue.Scalar(2_000_000_000d), MathBlockValue.Scalar(1d)];
        var sample = operation.Evaluate(sampleInputs);
        Assert.True(sample.IsValid);
        Assert.Equal(2_000_000_000d - 1d, sample.AsScalar(), 3);
    }
}
