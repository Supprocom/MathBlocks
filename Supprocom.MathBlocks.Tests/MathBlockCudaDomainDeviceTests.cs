using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CUDA device tests of the domain options and non-convergence: each compiles the device source for the options, runs the
/// operation and compares the bits with CoreCLR under the same options. They need a CUDA device and are excluded from the device-free runs.
/// </summary>
public sealed class MathBlockCudaDomainDeviceTests
{
    // The larger values of the device run: subset size 24, 8192 states, 2,000,000 generated elements.
    private static IEnumerable<MathBlockDomainWiringTests.Case> LargeCases()
    {
        yield return new("combinatorics.nonempty-subset-sums@1", [MathBlockValue.Vector(Enumerable.Range(1, 24).Select(value => (double)value))], new() { MaximumExplicitSubsetSize = 24 });
        yield return new("state.transition-counts@1", [MathBlockValue.Vector([0d, 1d, 8191d, 1d]), MathBlockValue.Scalar(8192d)], new() { MaximumStateCount = 8192 });
        yield return new("vector.repeat@1", [MathBlockValue.Scalar(1.25d), MathBlockValue.Scalar(2_000_000d)], new() { MaximumGeneratedVectorLength = 2_000_000 });
        yield return new("vector.linspace@1", [MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2_000_000d)], new() { MaximumGeneratedVectorLength = 2_000_000 });
        yield return new("matrix.identity@1", [MathBlockValue.Scalar(5_000d)], new() { MaximumMatrixSize = 5_000 });
    }

    /// <summary>Gets the names of the cases of each direction, as <c>direction:identity</c>.</summary>
    public static TheoryData<string> CaseNames()
    {
        var data = new TheoryData<string>();
        foreach (var item in MathBlockDomainWiringTests.RaisedCases())
            data.Add("raised:" + item.Identity);
        foreach (var item in MathBlockDomainWiringTests.LoweredCases())
            data.Add("lowered:" + item.Identity);
        foreach (var item in LargeCases())
            data.Add("large:" + item.Identity);
        return data;
    }

    private static MathBlockDomainWiringTests.Case Find(string name)
    {
        var separator = name.IndexOf(':', StringComparison.Ordinal);
        var identity = name[(separator + 1)..];
        IEnumerable<MathBlockDomainWiringTests.Case> cases = name[..separator] switch
        {
            "raised" => MathBlockDomainWiringTests.RaisedCases(),
            "lowered" => MathBlockDomainWiringTests.LoweredCases(),
            _ => LargeCases()
        };
        return cases.First(item => string.Equals(item.Identity, identity, StringComparison.Ordinal));
    }

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) Build(string identity, IReadOnlyList<MathBlockValue> values)
    {
        var separator = identity.LastIndexOf('@');
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = values.Select((value, index) => builder.Input($"input{index}", value.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(identity[..separator], 1, nodes)).Build();
        var named = values.Select((value, index) => (Name: $"input{index}", Value: value)).ToDictionary(item => item.Name, item => item.Value, StringComparer.Ordinal);
        return (program, named);
    }

    /// <summary>Verifies the device gives the CoreCLR value, or the CoreCLR invalid, under the domain options the device source is built with.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(CaseNames))]
    public void CUDAMatchesCoreCLRUnderTheDomainOptions(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var item = Find(name);
        var (program, inputs) = Build(item.Identity, item.Inputs);

        var coreclr = MathBlocksCoreCLRWorker.Create(item.Other).Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs, item.Other);
        var cuda = compiled.Execute(inputs)["result"];

        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cuda), $"{name}: CoreCLR valid={coreclr.IsValid}, CUDA valid={cuda.IsValid}");
        Assert.Equal(name.StartsWith("lowered:", StringComparison.Ordinal), !coreclr.IsValid);
    }

    private static (long Cuda, long CoreCLR, bool CudaValid, bool CoreCLRValid) Counts(
        string identity,
        IReadOnlyList<MathBlockValue> values,
        MathBlockDomainOptions domain,
        string counted)
    {
        var (program, inputs) = Build(identity, values);
        var coreclr = MathBlocksCoreCLRWorker.Create(domain).ExecuteWithDiagnostics(program, inputs);
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs, domain);
        var cuda = compiled.ExecuteWithDiagnostics(inputs);
        Assert.True(MathBlockDomainWiringTests.Same(coreclr.Outputs["result"], cuda.Outputs["result"]), identity);
        Assert.Equal(coreclr.NonConvergedEvaluations, cuda.NonConvergedEvaluations);
        Assert.Equal(compiled.NonConvergedEvaluations, cuda.NonConvergedEvaluations);
        return (
            cuda.NonConvergedEvaluations.GetValueOrDefault(counted),
            coreclr.NonConvergedEvaluations.GetValueOrDefault(counted),
            cuda.Outputs["result"].IsValid,
            coreclr.Outputs["result"].IsValid);
    }

    /// <summary>Verifies the incomplete beta counts one non-converged evaluation on the device as on CoreCLR, under both policies, and converges from 513 iterations.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [InlineData(MathBlockNonConvergencePolicy.Estimate, 256, 1L, true)]
    [InlineData(MathBlockNonConvergencePolicy.Invalid, 256, 1L, false)]
    [InlineData(MathBlockNonConvergencePolicy.Estimate, 513, 0L, true)]
    [InlineData(MathBlockNonConvergencePolicy.Invalid, 513, 0L, true)]
    public void CUDACountsTheIncompleteBetaThatDoesNotConverge(MathBlockNonConvergencePolicy policy, int iterations, long expected, bool valid)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var domain = new MathBlockDomainOptions { IncompleteBetaMaximumIterations = iterations, IncompleteBetaNonConvergence = policy };

        var counts = Counts(
            "special.regularized-incomplete-beta@1",
            [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(1e6d), MathBlockValue.Scalar(1e6d)],
            domain,
            "special.regularized-incomplete-beta@1");

        Assert.Equal(expected, counts.Cuda);
        Assert.Equal(expected, counts.CoreCLR);
        Assert.Equal(valid, counts.CudaValid);
        Assert.Equal(valid, counts.CoreCLRValid);
    }

    /// <summary>Verifies each Jacobi operation counts a non-converged evaluation on the device as on CoreCLR, under both policies.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [InlineData("matrix.symmetric-eigenvalues@1", MathBlockNonConvergencePolicy.Estimate)]
    [InlineData("matrix.symmetric-eigenvalues@1", MathBlockNonConvergencePolicy.Invalid)]
    [InlineData("matrix.largest-symmetric-eigenvalue@1", MathBlockNonConvergencePolicy.Estimate)]
    [InlineData("matrix.smallest-symmetric-eigenvalue@1", MathBlockNonConvergencePolicy.Invalid)]
    [InlineData("matrix.spectral-norm@1", MathBlockNonConvergencePolicy.Estimate)]
    [InlineData("matrix.spectral-norm@1", MathBlockNonConvergencePolicy.Invalid)]
    public void CUDACountsTheJacobiEvaluationThatEndsAtItsBudget(string identity, MathBlockNonConvergencePolicy policy)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var size = 6;
        var entries = new double[size * size];
        for (var row = 0; row < size; row++)
        {
            for (var column = row; column < size; column++)
            {
                entries[row * size + column] = entries[column * size + row] = Math.Sin(1d + row * 7 + column * 3) + 2d;
            }
        }

        MathBlockValue[] values = string.Equals(identity, "matrix.spectral-norm@1", StringComparison.Ordinal)
            ? [MathBlockValue.Matrix(new MathBlockMatrix(size, size, entries)), MathBlockValue.Scalar(10d)]
            : [MathBlockValue.Matrix(new MathBlockMatrix(size, size, entries))];
        var domain = new MathBlockDomainOptions { JacobiRotationMultiplier = 1, JacobiNonConvergence = policy };

        var counts = Counts(identity, values, domain, identity);

        Assert.Equal(1L, counts.Cuda);
        Assert.Equal(1L, counts.CoreCLR);
        Assert.Equal(policy == MathBlockNonConvergencePolicy.Estimate, counts.CudaValid);
    }

    /// <summary>Verifies the elementwise incomplete-beta form counts each non-converged row on the device.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDACountsEachNonConvergedRowOfTheElementwiseForm()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var form = "elementwise.special.regularized-incomplete-beta@1";

        var counts = Counts(
            form,
            [MathBlockValue.Vector([0.5d, 0.5d, 0.5d]), MathBlockValue.Scalar(1e6d), MathBlockValue.Scalar(1e6d), MathBlockValue.Scalar(-1d)],
            MathBlockDomainOptions.Default,
            form);

        Assert.Equal(3L, counts.Cuda);
        Assert.Equal(3L, counts.CoreCLR);
    }

    /// <summary>Verifies the counters are zeroed before each execution: a converging execution after a non-converging one reports nothing.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void ACudaExecutionZeroesTheCountersFirst()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        MathBlockValue[] hard = [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(1e6d), MathBlockValue.Scalar(1e6d)];
        MathBlockValue[] easy = [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(2d), MathBlockValue.Scalar(3d)];
        var (program, inputs) = Build("special.regularized-incomplete-beta@1", hard);
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs, MathBlockDomainOptions.Default);

        Assert.Equal(1L, compiled.ExecuteWithDiagnostics(inputs).NonConvergedEvaluations["special.regularized-incomplete-beta@1"]);
        var second = compiled.ExecuteWithDiagnostics(Build("special.regularized-incomplete-beta@1", easy).Inputs);

        Assert.Empty(second.NonConvergedEvaluations);
        Assert.Empty(compiled.NonConvergedEvaluations);
    }

    /// <summary>Verifies a consumer kernel compiles after the device source of the domain options and reaches the counter global by its public name.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void ADomainOptionConsumerCompilesAndSeesTheCounterSymbol()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var consumer =
            $"extern \"C\" __global__ void consumer_count(unsigned long long* total) {{ *total = {MathBlockCudaDeviceModule.NonConvergenceCountsSymbol}[0]; }}";

        var ptx = MathBlockCudaDeviceModule.CompilePtx(consumer, "domain-consumer.cu", new MathBlockDomainOptions { MaximumStateCount = 8192 });

        Assert.Contains(MathBlockCudaDeviceModule.NonConvergenceCountsSymbol, System.Text.Encoding.ASCII.GetString(ptx), StringComparison.Ordinal);
    }

    /// <summary>Verifies the device ordinal: 0 is the default device, and an ordinal past the device count throws naming the count.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void ADeviceOrdinalPastTheDeviceCountNamesTheCount()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (program, inputs) = Build("special.regularized-incomplete-beta@1", [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(2d), MathBlockValue.Scalar(3d)]);

        using var first = new MathBlocksCUDAWorker().CompileWithOptions(program, new MathBlocksCudaOptions { DeviceOrdinal = 0 }, inputs);
        var thrown = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(
            program, new MathBlocksCudaOptions { DeviceOrdinal = 1_000_000 }, inputs));

        Assert.Equal(0, first.Options.DeviceOrdinal);
        Assert.Equal(nameof(MathBlocksCudaOptions.DeviceOrdinal), thrown.ParamName);
        Assert.Contains("cuDeviceGetCount reports", thrown.Message, StringComparison.Ordinal);
        Assert.True(MathBlockDomainWiringTests.Same(
            MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"],
            first.Execute(inputs)["result"]));
    }
}
