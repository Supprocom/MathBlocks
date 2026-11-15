using System.Diagnostics;
using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests;

// The elementwise ballot count on price-like integer pairs: the loop of the binomial coefficient is cut short, so a
// million rows finish quickly, and the bits are the CoreCLR lift's.
public sealed partial class MathBlockCudaWorkerTests
{
    private const int CostGuardRows = 1_000_000;

    /// <summary>
    /// Verifies the elementwise form of <c>combinatorics.ballot-count</c> over one million rows of integer pairs between 1,000 and
    /// 1,000,000 (a above b, a below b and a equal to b) runs within two seconds and returns the CoreCLR lift's bits, validity and fill.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "ElementwiseCuda")]
    public void CUDABallotCountOnPriceLikePairsIsFastAndMatchesTheCoreCLRLift()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        const string source = "combinatorics.ballot-count";
        var random = new Random(61_000);
        var leading = new double[CostGuardRows];
        var trailing = new double[CostGuardRows];
        for (var row = 0; row < CostGuardRows; row++)
        {
            leading[row] = 1_000 + random.Next(0, 999_000);
            trailing[row] = row % 10 == 0 ? leading[row] : 1_000 + random.Next(0, 999_000);
        }

        MathBlockValue[] arguments = [MathBlockValue.Vector(leading), MathBlockValue.Vector(trailing)];
        var formInputs = ElementwiseFormInputs(source, arguments, ElementwiseSentinel);
        var coreclr = Form(source).Evaluate(formInputs);
        var worker = new MathBlocksCUDAWorker();
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = formInputs.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(Form(source).Identifier, Form(source).Version, nodes)).Build();
        using var compiled = worker.Compile(program, NameWindowInputs(formInputs));
        var watch = Stopwatch.StartNew();
        var cuda = compiled.Execute(NameWindowInputs(formInputs))["result"];
        watch.Stop();

        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(2), $"The ballot count over {CostGuardRows} rows took {watch.Elapsed.TotalMilliseconds} ms.");
        Assert.Null(DescribeWindowDifference(coreclr, cuda));
        Assert.True(coreclr.IsValid);
    }
}
