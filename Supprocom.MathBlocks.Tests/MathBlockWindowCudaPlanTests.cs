using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CUDA contracts and plans of the window forms without a CUDA device.</summary>
public sealed class MathBlockWindowCudaPlanTests
{
    private const double Fill = -1d;

    /// <summary>
    /// Verifies each window form and sibling has a family 11 contract with opcode 2 * source + sibling, the six
    /// window-accurate forms following the 53 window sources.
    /// </summary>
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

        for (var index = 0; index < MathBlockWindowM2TestSupport.AccurateNames.Length; index++)
        {
            var name = MathBlockWindowM2TestSupport.AccurateNames[index];
            var form = MathBlockCudaDeviceModule.GetOperation($"window-accurate.{name}@1");
            var sibling = MathBlockCudaDeviceModule.GetOperation($"window-accurate-valid.{name}@1");
            Assert.Equal(MathBlockCudaOperationFamily.Window, form.Family);
            Assert.Equal(MathBlockCudaOperationFamily.Window, sibling.Family);
            Assert.Equal(2 * (SourceIdentifiers.Length + index), form.Opcode);
            Assert.Equal(2 * (SourceIdentifiers.Length + index) + 1, sibling.Opcode);
            Assert.Equal(MathBlockWindowM2TestSupport.AccurateForm(name).Arity, form.Arity);
            Assert.Equal(MathBlockWindowM2TestSupport.AccurateValidity(name).Arity, sibling.Arity);
        }

        Assert.Equal(
            118,
            MathBlockCudaDeviceModule.Operations.Count(contract => contract.Family == MathBlockCudaOperationFamily.Window));
        Assert.Equal(537, MathBlocksCUDAWorker.SupportedBlockIdentities.Count);
        Assert.Equal(
            118,
            MathBlockCatalog.Standard.Operations.Count(operation =>
                operation.Identifier.StartsWith("window", StringComparison.Ordinal)));
    }

    /// <summary>
    /// Verifies the plan gives each thread the scratch of the planned width and fits all slices of the grid in the
    /// 256 MiB budget: Theil-Sen w(w - 1), pseudomedian w(w + 1), distance correlation, MAD and Spearman 2w, the
    /// order statistics and geometric mean w, every other source none. The median and quantile threads each take a
    /// block of max(2w, 32) rows, so their grid is smaller.
    /// </summary>
    [Theory]
    [InlineData("statistics.theil-sen-slope", 302_893, 96, 261_488_640)]
    [InlineData("statistics.pseudomedian", 302_893, 96, 266_993_664)]
    [InlineData("statistics.distance-correlation", 302_893, 96, 268_369_920)]
    [InlineData("statistics.interquartile-range", 1_000, 17, 278_528)]
    [InlineData("statistics.median-absolute-deviation", 1_000, 17, 278_528)]
    [InlineData("statistics.spearman-correlation", 1_000, 17, 278_528)]
    [InlineData("vector.quantile", 1_000, 17, 17_408)]
    [InlineData("vector.median", 302_893, 96, 1_277_952)]
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

    /// <summary>
    /// Verifies the window-accurate plans give each thread one exact accumulator (285 words) for the sum and mean
    /// and two for the variances and deviations, whatever the width, with one thread per block of max(2w, 32) rows.
    /// </summary>
    [Theory]
    [InlineData("sum", 302_893, 96, 13 * 128 * 285 * 8)]
    [InlineData("mean", 302_893, 2, 74 * 128 * 285 * 8)]
    [InlineData("population-variance", 302_893, 96, 13 * 128 * 570 * 8)]
    [InlineData("sample-standard-deviation", 302_893, 17, 70 * 128 * 570 * 8)]
    [InlineData("sample-variance", 6, 3, 128 * 570 * 8)]
    public void WindowAccurateCUDAPlanGivesEachThreadAConstantAccumulatorScratch(
        string name,
        int count,
        int width,
        int expectedScratchBytes)
    {
        var x = MathBlockValue.Vector(Enumerable.Range(0, count).Select(row => (row % 7) * 0.5d).ToArray());
        var form = MathBlockWindowM2TestSupport.AccurateForm(name);
        var unit = form.ResolveOutputType([x.Type, MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
        MathBlockValue[] formInputs = [x, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Fill, unit)];
        MathBlockValue[] siblingInputs = [x, MathBlockValue.Scalar(width)];
        var formPlan = MathBlockCudaDeviceModule.GetOperation($"window-accurate.{name}@1").PlanCUDA(formInputs);
        var siblingPlan = MathBlockCudaDeviceModule.GetOperation($"window-accurate-valid.{name}@1").PlanCUDA(siblingInputs);

        Assert.Equal(expectedScratchBytes, formPlan.ScratchBytes);
        Assert.Equal(expectedScratchBytes, siblingPlan.ScratchBytes);
        Assert.Equal(count, formPlan.OutputCapacity);
        Assert.Equal(MathBlockValueKind.Vector, formPlan.OutputType.Kind);
        Assert.Equal(MathBlockValueKind.BooleanVector, siblingPlan.OutputType.Kind);
    }

    /// <summary>
    /// Verifies an exact width outside 1 .. n plans an always-invalid output (no payload, no scratch, the planned
    /// type), as CoreCLR returns an invalid value of that type.
    /// </summary>
    [Theory]
    [InlineData(0)]
    [InlineData(-3)]
    [InlineData(301)]
    public void WindowCUDAPlanMakesAnExactWidthOutsideTheSeriesAlwaysInvalid(int width)
    {
        var series = CreateSourceInputs("statistics.pearson-correlation", 300, 2, 12);
        var contract = MathBlockCudaDeviceModule.GetOperation("window.statistics.pearson-correlation@1");
        var inputs = FormInputs(series, width, FillFor("statistics.pearson-correlation", series));

        var plan = contract.PlanCUDA(inputs);
        var coreclr = Form("statistics.pearson-correlation").Evaluate(inputs);

        Assert.Equal(0, plan.OutputCapacity);
        Assert.Equal(0, plan.ScratchBytes);
        Assert.False(coreclr.IsValid);
        Assert.Equal(coreclr.Type, plan.OutputType);
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
