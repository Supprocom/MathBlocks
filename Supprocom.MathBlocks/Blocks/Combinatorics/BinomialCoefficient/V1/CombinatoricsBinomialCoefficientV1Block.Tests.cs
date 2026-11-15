namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>combinatorics.binomial-coefficient@1</c> operation contract.</summary>
public sealed class CombinatoricsBinomialCoefficientV1BlockTests
{
    /// <summary>Checks the <c>combinatorics.binomial-coefficient@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("combinatorics.binomial-coefficient@1");

    /// <summary>
    /// Checks that the loop of the released 0.6.1 ends at +Infinity for every k from 600 on, with n at 2k, 2k + 1 and 3k, so the
    /// early return for k >= 600 gives the same value.
    /// </summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void TheLoopOverflowsForEveryKFrom600()
    {
        for (var k = 600; k <= 720; k++)
        {
            foreach (var n in new[] { 2 * k, 2 * k + 1, 3 * k, 100_000 })
            {
                Assert.True(double.IsPositiveInfinity(CombinatoricsCostGuardReference.Today(n, k)), $"The loop is finite at ({n}, {k}).");
                Assert.True(double.IsPositiveInfinity(MathBlockProbability.BinomialCoefficient(n, k)), $"BinomialCoefficient({n}, {k}) is finite.");
            }
        }
    }

    /// <summary>Checks that BinomialCoefficient returns the bits of the 0.6.1 loop on every grid pair, including negative arguments and k above n.</summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void MatchesTheReferenceLoopOnTheGrid()
    {
        var mismatches = new List<string>();
        var pairs = CombinatoricsCostGuardReference.Pairs([.. CombinatoricsCostGuardReference.Values, -1, -5]);
        for (var index = 0; index < pairs.Length; index++)
        {
            var (n, k) = pairs[index];
            var expected = BitConverter.DoubleToInt64Bits(CombinatoricsCostGuardReference.Today(n, k));
            var actual = BitConverter.DoubleToInt64Bits(MathBlockProbability.BinomialCoefficient(n, k));
            if (expected != actual)
                mismatches.Add($"({n}, {k})");
        }

        Assert.True(mismatches.Count == 0, string.Join(", ", mismatches.Take(20)));
        Assert.True(pairs.Length > 1000);
    }

    /// <summary>Checks that the operation is valid exactly where the 0.6.1 loop was finite.</summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void ValidityMatchesTheReferenceLoop()
    {
        var operation = MathBlockCatalog.Standard.Get("combinatorics.binomial-coefficient");
        var pairs = CombinatoricsCostGuardReference.Pairs(CombinatoricsCostGuardReference.Values);
        var disagreements = new List<string>();
        for (var index = 0; index < pairs.Length; index++)
        {
            var (n, k) = pairs[index];
            MathBlockValue[] inputs = [MathBlockValue.Scalar(n), MathBlockValue.Scalar(k)];
            var result = operation.Evaluate(inputs);
            var reference = CombinatoricsCostGuardReference.Today(n, k);
            var expectedValid = double.IsFinite(reference);
            if (result.IsValid != expectedValid || (expectedValid && BitConverter.DoubleToInt64Bits(result.AsScalar()) != BitConverter.DoubleToInt64Bits(reference)))
                disagreements.Add($"({n}, {k})");
        }

        Assert.True(disagreements.Count == 0, string.Join(", ", disagreements.Take(20)));
    }

    /// <summary>
    /// Checks that BinomialCoefficient returns the bits of the 0.6.1 loop for every k from 300 to 599, where the loop may overflow part way
    /// and stop at the first +Infinity, with n at 2k, 2k + 1, 3k, 10k and two larger values.
    /// </summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void StoppingAtTheFirstInfinityKeepsTheBitsBelow600()
    {
        var mismatches = new List<string>();
        var infinite = 0;
        for (var k = 300; k <= 599; k++)
        {
            foreach (var n in new[] { 2 * k, 2 * k + 1, 3 * k, 10 * k, 100_000, 1_000_000 })
            {
                var expected = CombinatoricsCostGuardReference.Today(n, k);
                if (double.IsPositiveInfinity(expected))
                    infinite++;
                if (BitConverter.DoubleToInt64Bits(expected) != BitConverter.DoubleToInt64Bits(MathBlockProbability.BinomialCoefficient(n, k)))
                    mismatches.Add($"({n}, {k})");
            }
        }

        Assert.True(mismatches.Count == 0, string.Join(", ", mismatches.Take(20)));
        Assert.True(infinite > 100, $"Only {infinite} loops overflowed.");
    }
}
