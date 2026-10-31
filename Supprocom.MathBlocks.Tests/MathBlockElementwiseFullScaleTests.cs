using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CoreCLR elementwise forms at the full PatternResearcher series length.</summary>
public sealed class MathBlockElementwiseFullScaleTests
{
    private const int FullLength = 302_893;
    private const double Sentinel = -98_765.25d;

    /// <summary>Gets every source identifier of the elementwise forms.</summary>
    public static TheoryData<string> Sources => [.. SourceIdentifiers];

    /// <summary>
    /// Verifies form and sibling rows equal the source on each row bit for bit at 302,893 rows, for every vector
    /// or scalar choice per argument. The form and its sibling run concurrently.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    [Trait("Category", "ElementwiseFullScale")]
    public void FullLengthRowsEqualTheSourceOnEachRowBitForBit(string source)
    {
        var failures = new List<string>();
        foreach (var mask in BroadcastMasks(source))
        {
            var arguments = CreateArguments(source, FullLength, mask, 41_000 + mask);
            MathBlockValue form = default;
            MathBlockValue validity = default;
            Parallel.Invoke(
                () => form = Form(source).Evaluate([.. arguments, MathBlockValue.Scalar(Sentinel)]),
                () => validity = Validity(source).Evaluate(arguments));
            var reference = Reference(source, arguments);
            failures.AddRange(Compare($"{source} [{DescribeMask(source, mask)}]", Sentinel, form, validity, reference));
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }
}
