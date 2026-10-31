using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CUDA contracts and plans of the window forms without a CUDA device.</summary>
public sealed class MathBlockWindowCudaPlanTests
{
    private const double Fill = -1d;

    /// <summary>Verifies each window form and sibling has a family 11 contract with opcode 2 * source + sibling.</summary>
    [Fact]
    public void WindowCUDAContractsUseFamilyElevenWithOpcodeTwiceTheSourcePlusSibling()
    {
        Assert.Equal(11, (int)MathBlockCudaOperationFamily.Window);
        for (var index = 0; index < SourceIdentifiers.Length; index++)
        {
            var form = MathBlockCudaDeviceModule.GetOperation($"window.{SourceIdentifiers[index]}@1");
            var sibling = MathBlockCudaDeviceModule.GetOperation($"window-valid.{SourceIdentifiers[index]}@1");
            Assert.Equal(MathBlockCudaOperationFamily.Window, form.Family);
            Assert.Equal(MathBlockCudaOperationFamily.Window, sibling.Family);
            Assert.Equal(2 * index, form.Opcode);
            Assert.Equal(2 * index + 1, sibling.Opcode);
            Assert.Equal(128u, form.NativeBlockSize);
            Assert.Equal(Form(SourceIdentifiers[index]).Arity, form.Arity);
            Assert.Equal(Validity(SourceIdentifiers[index]).Arity, sibling.Arity);
        }

        Assert.Equal(
            106,
            MathBlockCudaDeviceModule.Operations.Count(contract => contract.Family == MathBlockCudaOperationFamily.Window));
        Assert.Equal(443, MathBlocksCUDAWorker.SupportedBlockIdentities.Count);
        Assert.DoesNotContain(
            MathBlockCatalog.Standard.Operations,
            operation => operation.Identifier.StartsWith("window", StringComparison.Ordinal));
    }

    /// <summary>
    /// Verifies the plan gives each thread the scratch of the planned width and fits all slices of the grid in the
    /// 256 MiB budget: Theil-Sen w(w - 1), pseudomedian w(w + 1), distance correlation, MAD and Spearman 2w, the
    /// order statistics and geometric mean w, every other source none.
    /// </summary>
    [Theory]
    [InlineData("statistics.theil-sen-slope", 302_893, 96, 261_488_640)]
    [InlineData("statistics.pseudomedian", 302_893, 96, 266_993_664)]
    [InlineData("statistics.distance-correlation", 302_893, 96, 268_369_920)]
    [InlineData("statistics.interquartile-range", 1_000, 17, 139_264)]
    [InlineData("statistics.median-absolute-deviation", 1_000, 17, 278_528)]
    [InlineData("statistics.spearman-correlation", 1_000, 17, 278_528)]
    [InlineData("vector.quantile", 1_000, 17, 139_264)]
    [InlineData("vector.geometric-mean", 1_000, 17, 139_264)]
    [InlineData("statistics.theil-sen-slope", 6, 3, 6_144)]
    [InlineData("statistics.theil-sen-slope", 6, 1, 0)]
    [InlineData("statistics.pseudomedian", 6, 1, 2_048)]
    [InlineData("vector.sum", 302_893, 96, 0)]
    [InlineData("statistics.kendall-tau-b", 302_893, 96, 0)]
    public void WindowCUDAPlanSizesEachThreadsScratchFromThePlannedWidth(
        string source,
        int count,
        int width,
        int expectedScratchBytes)
    {
        var series = CreateSourceInputs(source, count, width, 11);
        var formPlan = MathBlockCudaDeviceModule.GetOperation($"window.{source}@1")
            .PlanCUDA(FormInputs(series, width, FillFor(source, series)));
        var siblingPlan = MathBlockCudaDeviceModule.GetOperation($"window-valid.{source}@1")
            .PlanCUDA(ValidityInputs(series, width));

        Assert.Equal(expectedScratchBytes, formPlan.ScratchBytes);
        Assert.Equal(expectedScratchBytes, siblingPlan.ScratchBytes);
        Assert.Equal(count, formPlan.OutputCapacity);
        Assert.Equal(count, formPlan.OutputRows);
        Assert.Equal(MathBlockValueKind.Vector, formPlan.OutputType.Kind);
        Assert.Equal(MathBlockValueKind.BooleanVector, siblingPlan.OutputType.Kind);
        Assert.Equal(count, siblingPlan.OutputRows);
    }

    /// <summary>Verifies an exact width outside 1 .. n is rejected by the static window authority.</summary>
    [Theory]
    [InlineData(0)]
    [InlineData(-3)]
    [InlineData(301)]
    public void WindowCUDAPlanRejectsAnExactWidthOutsideTheSeries(int width)
    {
        var series = CreateSourceInputs("statistics.pearson-correlation", 300, 2, 12);
        var contract = MathBlockCudaDeviceModule.GetOperation("window.statistics.pearson-correlation@1");

        var exception = Assert.Throws<InvalidOperationException>(() =>
            contract.PlanCUDA(FormInputs(series, width, FillFor("statistics.pearson-correlation", series))));
        Assert.Contains("window authority", exception.Message, StringComparison.Ordinal);
    }

    /// <summary>Verifies unequal series lengths give the shapeless type that the CoreCLR lift's invalid result has.</summary>
    [Fact]
    public void WindowCUDAPlanGivesNoRowAuthorityForUnequalSeriesLengths()
    {
        const string source = "statistics.pearson-correlation";
        var series = CreateSourceInputs(source, 300, 17, 13);
        series[1] = MathBlockValue.Vector(series[1].AsVector().ToArray()[..299], series[1].Type.Unit);
        var inputs = FormInputs(series, 17, FillFor(source, series));

        var plan = MathBlockCudaDeviceModule.GetOperation($"window.{source}@1").PlanCUDA(inputs);
        var coreclr = Form(source).Evaluate(inputs);

        Assert.False(coreclr.IsValid);
        Assert.Equal(0, plan.OutputRows);
        Assert.Equal(300, plan.OutputCapacity);
        Assert.Equal(coreclr.Type, new MathBlockType(plan.OutputType.Kind, plan.OutputType.Unit, plan.OutputRows, 0));
    }

    private static MathBlockValue FillFor(string source, MathBlockValue[] series) =>
        MathBlockValue.Scalar(
            Fill,
            Form(source).ResolveOutputType(
                [.. series.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit);
}
