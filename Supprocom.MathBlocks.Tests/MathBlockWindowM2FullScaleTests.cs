using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the M2 window forms at the full PatternResearcher series length.</summary>
public sealed class MathBlockWindowM2FullScaleTests(ITestOutputHelper output)
{
    private const int FullLength = 302_893;

    private static readonly int[] Widths = [2, 17, 96];

    /// <summary>Gets the sources whose window forms have an M2 kernel.</summary>
    public static TheoryData<string> Sources => [.. KernelSources];

    /// <summary>Gets the input families of the exactness tests.</summary>
    public static TheoryData<string> Families => MathBlockWindowAccurateTests.Families;

    /// <summary>
    /// Verifies the kernel forms and siblings equal the direct lift bit for bit at 302,893 rows and widths 2, 17 and
    /// 96, on series with signed zeros, ties, constant runs and monotone runs.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    [Trait("Category", "WindowFullScale")]
    public void KernelRowsEqualTheDirectLiftBitForBit(string source)
    {
        var failures = new List<string>();
        foreach (var (name, series) in MathBlockWindowFastPathTests.CreateSeries(FullLength, 302_893))
        {
            if (string.Equals(name, "constant", StringComparison.Ordinal) ||
                string.Equals(name, "signed-zeros", StringComparison.Ordinal))
                continue;
            foreach (var width in Widths)
            {
                foreach (var parameters in MathBlockWindowFastPathTests.Parameters(source).Where(p => p.Length == 0 || p[0] is 0.3d or 0.5d or 1d))
                    failures.AddRange(MathBlockWindowFastPathTests.Compare(source, name, series, width, parameters));
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(40)));
    }

    /// <summary>
    /// Verifies every computed row of the six accurate forms is within its stated bound at 302,893 rows and widths 2,
    /// 17 and 96.
    /// </summary>
    [Theory]
    [MemberData(nameof(Families))]
    [Trait("Category", "WindowFullScale")]
    public void AccurateErrorsStayWithinTheStatedBounds(string family)
    {
        var x = MathBlockWindowAccurateTests.CreateFamily(family, FullLength, 302_893);
        var report = new List<string>();
        var failures = new List<string>();
        foreach (var width in Widths)
            failures.AddRange(MathBlockWindowAccurateTests.CheckBounds(family, x, width, report));
        output.WriteLine(string.Join(Environment.NewLine, report));

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(40)));
    }

    /// <summary>Verifies the batch equals each supported form evaluated alone at 302,893 rows.</summary>
    [Fact]
    [Trait("Category", "WindowFullScale")]
    public void BatchEqualsEachFormEvaluatedAlone()
    {
        var x = MathBlockValue.Vector(MathBlockWindowAccurateTests.CreateFamily("random-walk", FullLength, 7));
        foreach (var identity in MathBlocksWindowBatchTests.Identities)
        {
            var operation = MathBlocksWindowBatchTests.Resolve(identity);
            foreach (var parameters in MathBlocksWindowBatchTests.Parameters(identity).Take(1))
            {
                var results = MathBlocksWindowBatch.Evaluate(x, identity, parameters, Widths, 0d);
                for (var index = 0; index < Widths.Length; index++)
                {
                    var alone = operation.Evaluate([x, .. parameters, MathBlockValue.Scalar(Widths[index]), MathBlockValue.Scalar(0d)]);
                    var difference = Difference(alone, results[index]);
                    Assert.True(difference is null, $"{identity} w={Widths[index]}: {difference}");
                }
            }
        }
    }
}
