using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CoreCLR window forms at the full PatternResearcher series length.</summary>
public sealed class MathBlockWindowFullScaleTests
{
    private const int FullLength = 302_893;
    private const double Sentinel = -98_765.25d;

    // These sources cost O(w^2) or more per row; at width 96 the reference checks every 97th row and the last row.
    private static readonly string[] QuadraticSources =
    [
        "statistics.theil-sen-slope", "statistics.pseudomedian", "statistics.distance-correlation"
    ];

    /// <summary>Gets every source identifier of the window forms.</summary>
    public static TheoryData<string> Sources => [.. SourceIdentifiers];

    /// <summary>
    /// Verifies form and sibling rows equal the source on each window bit for bit at 302,893 rows and widths 2,
    /// 17 and 96. The form and its sibling run concurrently.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    [Trait("Category", "WindowFullScale")]
    public void FullLengthRowsEqualTheSourceOnEachWindowBitForBit(string source)
    {
        var failures = new List<string>();
        foreach (var width in new[] { 2, 17, 96 })
        {
            var sourceInputs = CreateSourceInputs(source, FullLength, width, 31_000 + width);
            var unit = Form(source).ResolveOutputType(
                [.. sourceInputs.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
            MathBlockValue form = default;
            MathBlockValue validity = default;
            Parallel.Invoke(
                () => form = Form(source).Evaluate(
                    FormInputs(sourceInputs, width, MathBlockValue.Scalar(Sentinel, unit))),
                () => validity = Validity(source).Evaluate(ValidityInputs(sourceInputs, width)));
            var stride = width == 96 && QuadraticSources.Contains(source, StringComparer.Ordinal) ? 97 : 1;
            var reference = Reference(source, sourceInputs, FullLength, width, stride);
            failures.AddRange(Compare(source, width, Sentinel, form, validity, reference));
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }
}
