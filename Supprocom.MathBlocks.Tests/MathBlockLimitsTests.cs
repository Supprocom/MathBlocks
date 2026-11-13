using System.Text.Json;
using Supprocom.MathBlocks.Cuda;
using Xunit.Abstractions;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains tests for the limit catalog of <see cref="MathBlockLimits"/>.</summary>
public sealed class MathBlockLimitsTests(ITestOutputHelper output)
{
    // Every row of the two hard-coded-limits audits (2026-11-13), with the record names that cover it.
    private static readonly Dictionary<string, string[]> RowRecords = new(StringComparer.Ordinal)
    {
        ["MB-1"] = ["cuda.window.maximum-width"],
        ["MB-2"] = ["cuda.window.scratch-budget-bytes"],
        ["MB-3"] = ["cuda.grid-x"],
        ["MB-4"] = ["fused.maximum-operation-nodes", "fused.maximum-vector-inputs", "fused.maximum-outputs"],
        ["MB-5"] = ["cuda.fused.maximum-blocks", "cuda.fused.block-size"],
        ["MB-6"] = ["cuda.block-size", "cuda.device-module.dispatcher-block-size"],
        ["MB-7"] = ["cuda.slot.size-bytes", "cuda.slot.maximum-count", "cuda.run.size-bytes", "cuda.graph-edge.size-bytes"],
        ["MB-8"] = ["cuda.window-accurate.accumulator-words", "cuda.window-accurate.accumulator-chunks", "cuda.window-accurate.variance-accumulator-words", "cuda.window-accurate.carry-flush-additions"],
        ["MB-9"] = ["domain.maximum-explicit-subset-size"],
        ["MB-10"] = ["domain.maximum-state-count"],
        ["MB-11"] = ["domain.lag", "domain.rolling-width"],
        ["MB-12"] = ["openmath.maximum-nodes", "openmath.maximum-outputs", "openmath.maximum-value-elements"],
        ["MB-13"] = ["coreclr.maximum-concurrency"],
        ["N-MB-1"] = ["domain.maximum-generated-vector-length"],
        ["N-MB-2"] = ["domain.incomplete-beta-maximum-iterations", "domain.incomplete-beta-non-convergence"],
        ["N-MB-3"] = ["units.dimension-count", "units.exponent-component"],
        ["N-MB-4"] = ["fused.maximum-source-arity", "fused.operation-count", "fused.row-block"],
        ["N-MB-5"] = ["domain.maximum-submodular-set-function-values", "domain.maximum-shapley-coalition-values", "domain.maximum-choquet-player-count"],
        ["N-MB-6"] = ["domain.maximum-maximal-minor-columns", "domain.maximum-totally-nonnegative-size"],
        ["N-MB-7"] = ["domain.maximum-matrix-size"],
        ["N-MB-8"] = ["domain.maximum-iteration-count"],
        ["N-MB-9"] = ["openmath.maximum-document-characters", "openmath.maximum-document-bytes", "interchange.maximum-document-characters", "interchange.maximum-document-utf8-bytes", "interchange.maximum-expression-elements", "interchange.maximum-expression-depth"],
        ["N-MB-10"] = ["cuda.device-ordinal"],
        ["N-MB-11"] = ["domain.jacobi-rotation-multiplier", "domain.jacobi-non-convergence", "matrix.exponential.taylor-terms", "scalar.cube-root.newton-steps"],
        ["N-MB-12"] = ["packaging.target-framework", "packaging.cuda-toolkit-minimum-major", "packaging.profile-1-operation-count"]
    };

    private static readonly string[] JsonFields =
        ["name", "operation", "kind", "device", "minimum", "maximum", "value", "unit", "option", "drivenBy", "rule"];

    /// <summary>Verifies every audit row has at least one record and every listed record exists.</summary>
    [Fact]
    public void EveryAuditRowHasARecord()
    {
        var names = MathBlockLimits.Resolve().Select(limit => limit.Name).ToHashSet(StringComparer.Ordinal);
        var expectedRows = Enumerable.Range(1, 13).Select(row => $"MB-{row}")
            .Concat(Enumerable.Range(1, 12).Select(row => $"N-MB-{row}"));

        Assert.Equal(expectedRows.Order(StringComparer.Ordinal), RowRecords.Keys.Order(StringComparer.Ordinal));
        foreach (var (row, records) in RowRecords)
        {
            Assert.NotEmpty(records);
            foreach (var record in records)
                Assert.True(names.Contains(record), $"{row}: no record named {record}.");
        }
    }

    /// <summary>Verifies the defaults equal the literals of earlier versions.</summary>
    [Fact]
    public void DefaultsEqualTheEarlierLiterals()
    {
        var limits = MathBlockLimits.Resolve();
        long Value(string name, string? operation = null) =>
            limits.Single(limit => Is(limit, name, operation)).Value!.Value;

        Assert.Equal(128, Value("cuda.block-size"));
        Assert.Equal(65_535, Value("cuda.grid-x"));
        Assert.Equal(256L * 1024 * 1024, Value("cuda.window.scratch-budget-bytes"));
        Assert.Equal(4_096, Value("cuda.fused.maximum-blocks"));
        Assert.Equal(256, Value("cuda.fused.block-size"));
        Assert.Equal(8_192, Value("fused.row-block"));
        Assert.Equal(0, Value("cuda.device-ordinal"));
        Assert.Equal(64, Value("fused.maximum-operation-nodes"));
        Assert.Equal(16, Value("fused.maximum-vector-inputs"));
        Assert.Equal(4, Value("fused.maximum-outputs"));
        Assert.Equal(3, Value("fused.maximum-source-arity"));
        Assert.True(Value("fused.operation-count") > 26);
        Assert.Equal(48, Value("cuda.slot.size-bytes"));
        Assert.Equal(285, Value("cuda.window-accurate.accumulator-words"));
        Assert.Equal(141, Value("cuda.window-accurate.accumulator-chunks"));
        Assert.Equal(570, Value("cuda.window-accurate.variance-accumulator-words"));
        Assert.Equal(134_217_728, Value("cuda.window-accurate.carry-flush-additions"));
        Assert.Equal(20, Value("domain.maximum-explicit-subset-size", "matrix.principal-minors@1"));
        Assert.Equal(20, Value("domain.maximum-explicit-subset-size", "combinatorics.nonempty-subset-sums@1"));
        Assert.Equal(20, Value("domain.maximum-explicit-subset-size", "transport.minimum-assignment@1"));
        Assert.Equal(4_096, Value("domain.maximum-state-count", "state.transition-counts@1"));
        Assert.Equal(1_000_000, Value("domain.maximum-generated-vector-length", "vector.repeat@1"));
        Assert.Equal(1_000_000, Value("domain.maximum-generated-vector-length", "vector.linspace@1"));
        Assert.Equal(1 << 12, Value("domain.maximum-submodular-set-function-values", "capacity.is-submodular@1"));
        Assert.Equal(1 << 20, Value("domain.maximum-shapley-coalition-values", "cooperative.shapley-values@1"));
        Assert.Equal(30, Value("domain.maximum-choquet-player-count", "capacity.choquet-integral@1"));
        Assert.Equal(20, Value("domain.maximum-maximal-minor-columns", "matrix.maximal-minors@1"));
        Assert.Equal(8, Value("domain.maximum-totally-nonnegative-size", "matrix.is-totally-nonnegative@1"));
        Assert.Equal(4_096, Value("domain.maximum-matrix-size", "matrix.identity@1"));
        Assert.Equal(256, Value("domain.incomplete-beta-maximum-iterations", "special.regularized-incomplete-beta@1"));
        Assert.Equal(0, Value("domain.incomplete-beta-non-convergence", "special.regularized-incomplete-beta@1"));
        Assert.Equal(64, Value("domain.jacobi-rotation-multiplier", "matrix.symmetric-eigenvalues@1"));
        Assert.Equal(48, Value("matrix.exponential.taylor-terms", "matrix.exponential@1"));
        Assert.Equal(3, Value("scalar.cube-root.newton-steps", "scalar.cube-root@1"));
        Assert.Equal(16 * 1024 * 1024, Value("openmath.maximum-document-characters"));
        Assert.Equal((16 * 1024 * 1024 * 3) + 3, Value("openmath.maximum-document-bytes"));
        Assert.Equal(6 * 16 * 1024 * 1024, Value("interchange.maximum-document-characters"));
        Assert.Equal(16 * 1024, Value("interchange.maximum-expression-elements"));
        Assert.Equal(256, Value("interchange.maximum-expression-depth"));
        Assert.Equal(337, Value("packaging.profile-1-operation-count"));
        Assert.Equal(12, Value("packaging.cuda-toolkit-minimum-major"));
        foreach (var iterative in new[] { "matrix.perron-vector@1", "matrix.perron-value@1", "matrix.spectral-norm@1", "markov.stationary-distribution@1", "graph.page-rank@1", "transport.sinkhorn-coupling@1" })
            Assert.Equal(10_000, Value("domain.maximum-iteration-count", iterative));
    }

    /// <summary>Verifies the window width records at the default block size: the per-form limits of the plan.</summary>
    [Fact]
    public void WindowWidthRecordsAtTheDefaultBlockSize()
    {
        var widths = MathBlockLimits.Resolve().Where(limit => Named(limit, "cuda.window.maximum-width")).ToList();

        // 59 window sources, each with a window and a window-valid form.
        Assert.Equal(118, widths.Count);
        var byValue = widths.GroupBy(limit => limit.Value!.Value).ToDictionary(group => group.Key, group => group.Count());
        Assert.Equal(5, byValue.Count);
        Assert.Equal(6, byValue[2_097_151]);
        Assert.Equal(8, byValue[1_048_575]);
        Assert.Equal(2, byValue[1_448]);
        Assert.Equal(2, byValue[1_447]);
        Assert.Equal(100, byValue[int.MaxValue]);
        Assert.All(widths, limit => Assert.Equal(limit.Maximum, limit.Value));
        Assert.All(widths.Where(limit => limit.Value != int.MaxValue), limit => Assert.Equal(MathBlockLimitKind.Derived, limit.Kind));
        Assert.All(widths.Where(limit => limit.Value == int.MaxValue), limit => Assert.Equal(MathBlockLimitKind.Fixed, limit.Kind));
        Assert.Equal(1_448, Width(widths, "window.statistics.theil-sen-slope@1"));
        Assert.Equal(1_447, Width(widths, "window.statistics.pseudomedian@1"));
        Assert.Equal(1_048_575, Width(widths, "window.statistics.distance-correlation@1"));
        Assert.Equal(1_048_575, Width(widths, "window-valid.statistics.distance-correlation@1"));
        Assert.Equal(int.MaxValue, Width(widths, "window-accurate.sum@1"));
    }

    /// <summary>Verifies the window width records follow the block size option.</summary>
    [Fact]
    public void WindowWidthRecordsFollowTheBlockSize()
    {
        var wide = MathBlockLimits.Resolve(new MathBlocksCudaOptions { BlockSize = 256 });
        var narrow = MathBlockLimits.Resolve(new MathBlocksCudaOptions { BlockSize = 64 });
        const string form = "window.statistics.distance-correlation@1";

        Assert.Equal(524_287, wide.Single(limit => Is(limit, "cuda.window.maximum-width", form)).Value);
        Assert.Equal(2_097_151, narrow.Single(limit => Is(limit, "cuda.window.maximum-width", form)).Value);
        var derived = wide.Single(limit => Is(limit, "cuda.window.maximum-width", form));
        Assert.Equal(MathBlockLimitKind.Derived, derived.Kind);
        Assert.Equal(["cuda.block-size"], derived.DrivenBy);
        Assert.Equal(256, wide.Single(limit => Named(limit, "cuda.block-size")).Value);
        Assert.Equal(256, wide.Single(limit => Named(limit, "cuda.device-module.dispatcher-block-size")).Value);
        Assert.Equal(1_024, Width(wide.Where(limit => Named(limit, "cuda.window.maximum-width")).ToList(), "window.statistics.theil-sen-slope@1"));
    }

    /// <summary>Verifies the records resolve against the given CUDA and domain options.</summary>
    [Fact]
    public void RecordsResolveAgainstTheGivenOptions()
    {
        var cuda = new MathBlocksCudaOptions
        {
            MaximumGridX = 1_000,
            WindowScratchBudgetBytes = 1L << 20,
            FusedMaximumBlocks = 7,
            FusedBlockSize = 32
        };
        var domain = new MathBlockDomainOptions { MaximumMatrixSize = 99, MaximumExplicitSubsetSize = 22, JacobiRotationMultiplier = 5 };

        var limits = MathBlockLimits.Resolve(cuda, domain);

        Assert.Equal(1_000, limits.Single(limit => Named(limit, "cuda.grid-x")).Value);
        Assert.Equal(1L << 20, limits.Single(limit => Named(limit, "cuda.window.scratch-budget-bytes")).Value);
        Assert.Equal(7, limits.Single(limit => Named(limit, "cuda.fused.maximum-blocks")).Value);
        Assert.Equal(32, limits.Single(limit => Named(limit, "cuda.fused.block-size")).Value);
        Assert.Equal(99, limits.Single(limit => Named(limit, "domain.maximum-matrix-size")).Value);
        Assert.Equal(99, limits.Single(limit => Named(limit, "cuda.device-module.maximum-matrix-size")).Value);
        Assert.All(limits.Where(limit => Named(limit, "domain.maximum-explicit-subset-size")), limit => Assert.Equal(22, limit.Value));
        Assert.All(limits.Where(limit => Named(limit, "domain.jacobi-rotation-multiplier")), limit => Assert.Equal(5, limit.Value));
    }

    /// <summary>Verifies the kinds, the devices and the rules the records carry.</summary>
    [Fact]
    public void KindsDevicesAndRulesAreAssigned()
    {
        var limits = MathBlockLimits.Resolve();
        MathBlockLimit One(string name) => limits.First(limit => Named(limit, name));

        Assert.Equal(MathBlockLimitKind.Launch, One("cuda.grid-x").Kind);
        Assert.Equal(MathBlockLimitKind.Launch, One("cuda.window.scratch-budget-bytes").Kind);
        Assert.Equal(MathBlockLimitKind.Launch, One("cuda.fused.maximum-blocks").Kind);
        Assert.Equal(MathBlockLimitKind.Launch, One("cuda.fused.block-size").Kind);
        Assert.Equal("speed-only; results unchanged", One("cuda.grid-x").Rule);
        Assert.Equal(MathBlockLimitKind.Option, One("cuda.block-size").Kind);
        Assert.Equal(MathBlockLimitKind.Option, One("coreclr.maximum-concurrency").Kind);
        Assert.Equal(MathBlockLimitKind.Option, One("cuda.device-ordinal").Kind);
        Assert.Equal(MathBlockLimitKind.Option, One("openmath.maximum-document-characters").Kind);
        Assert.Equal(MathBlockLimitKind.Option, One("interchange.maximum-expression-depth").Kind);
        Assert.Equal(MathBlockLimitKind.Fixed, One("cuda.slot.size-bytes").Kind);
        Assert.Equal(MathBlockLimitKind.Fixed, One("units.dimension-count").Kind);
        Assert.Equal(MathBlockLimitKind.Fixed, One("fused.maximum-source-arity").Kind);
        Assert.Equal(MathBlockLimitKind.Domain, One("domain.maximum-matrix-size").Kind);
        Assert.Equal(MathBlockLimitKind.Domain, One("domain.rolling-width").Kind);
        Assert.Equal(MathBlockLimitDevice.Cuda, One("cuda.grid-x").Device);
        Assert.Equal(MathBlockLimitDevice.CoreCLR, One("coreclr.maximum-concurrency").Device);
        Assert.Equal("MathBlocksCudaOptions.MaximumGridX", One("cuda.grid-x").Option);
        Assert.Equal("MathBlockDomainOptions.MaximumMatrixSize", One("domain.maximum-matrix-size").Option);

        var dispatcher = One("cuda.device-module.dispatcher-block-size");
        Assert.Equal(MathBlockLimitKind.Option, dispatcher.Kind);
        Assert.Equal(1, dispatcher.Minimum);
        Assert.Null(dispatcher.Maximum);
        Assert.Equal("caller-launched; the caller checks against its own kernel's maximum threads per block", dispatcher.Rule);
        Assert.Equal(
            ["lag", "rolling-width"],
            limits.Where(limit => Named(limit, "domain.lag") || Named(limit, "domain.rolling-width")).Select(limit => limit.Name["domain.".Length..]).Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal),
            StringComparer.Ordinal);
        Assert.Equal(MathBlockLimitKind.Domain, One("cuda.device-module.maximum-state-count").Kind);
    }

    /// <summary>Verifies every record that names an operation names a catalog operation, and record identities are unique.</summary>
    [Fact]
    public void RecordsNameCatalogOperationsAndAreUnique()
    {
        var identities = MathBlockCatalog.Standard.Operations.Select(operation => operation.Identity).ToHashSet(StringComparer.Ordinal);
        var limits = MathBlockLimits.Resolve();

        foreach (var limit in limits.Where(limit => limit.Operation is not null))
            Assert.True(identities.Contains(limit.Operation!), $"{limit.Name}: {limit.Operation} is not an operation.");
        Assert.Equal(limits.Count, limits.Select(limit => (limit.Name, limit.Operation)).Distinct().Count());
        Assert.All(limits, limit => Assert.False(string.IsNullOrWhiteSpace(limit.Rule)));
        Assert.All(limits, limit =>
        {
            if (limit.Minimum is { } minimum && limit.Value is { } value)
                Assert.True(value >= minimum, limit.Name);
            if (limit.Maximum is { } maximum && limit.Value is { } actual)
                Assert.True(actual <= maximum, limit.Name);
        });
        output.WriteLine($"records: {limits.Count}");
        foreach (var kind in Enum.GetValues<MathBlockLimitKind>())
            output.WriteLine($"{kind}: {limits.Count(limit => limit.Kind == kind)}");
    }

    /// <summary>Verifies the limits of one operation hold its own records and the global ones.</summary>
    [Fact]
    public void ForReturnsTheOperationAndTheGlobalLimits()
    {
        var identity = MathBlockLimits.For("matrix.identity@1");

        Assert.Contains(identity, limit => Is(limit, "domain.maximum-matrix-size", "matrix.identity@1"));
        Assert.Contains(identity, limit => Named(limit, "cuda.block-size") && limit.Operation is null);
        Assert.DoesNotContain(identity, limit => limit.Operation is not null && !string.Equals(limit.Operation, "matrix.identity@1", StringComparison.Ordinal));
        Assert.Equal(identity, MathBlockCatalog.Standard.Get("matrix.identity").Limits);
        Assert.Equal(
            ["domain.maximum-explicit-subset-size"],
            MathBlockLimits.For("matrix.principal-minors@1").Where(limit => limit.Operation is not null).Select(limit => limit.Name),
            StringComparer.Ordinal);
        Assert.Throws<ArgumentException>(() => MathBlockLimits.For("no.such-operation@1"));
        Assert.Throws<ArgumentNullException>(() => MathBlockLimits.For(null!));
        Assert.Equal(
            MathBlockLimits.Resolve(new MathBlocksCudaOptions { BlockSize = 256 }).Single(limit => Is(limit, "cuda.window.maximum-width", "window.statistics.theil-sen-slope@1")).Value,
            MathBlockLimits.For("window.statistics.theil-sen-slope@1", new MathBlocksCudaOptions { BlockSize = 256 }).Single(limit => Named(limit, "cuda.window.maximum-width")).Value);
    }

    /// <summary>Verifies options outside their range are load errors naming the limit.</summary>
    [Fact]
    public void OptionsOutsideTheirRangeAreLoadErrors()
    {
        Assert.Equal("BlockSize", Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(new MathBlocksCudaOptions { BlockSize = 0 })).ParamName);
        var tooWide = Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(new MathBlocksCudaOptions { BlockSize = 1_025 }));
        Assert.Contains("1,024 threads per block", tooWide.Message, StringComparison.Ordinal);
        Assert.Equal("MaximumGridX", Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(new MathBlocksCudaOptions { MaximumGridX = 0 })).ParamName);
        Assert.Equal("WindowScratchBudgetBytes", Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(new MathBlocksCudaOptions { WindowScratchBudgetBytes = 0 })).ParamName);
        Assert.Equal("MaximumMatrixSize", Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(domain: new MathBlockDomainOptions { MaximumMatrixSize = 16_384 })).ParamName);
        Assert.Equal("MaximumExplicitSubsetSize", Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.For("matrix.identity@1", domain: new MathBlockDomainOptions { MaximumExplicitSubsetSize = 27 })).ParamName);
    }

    /// <summary>Verifies the JSON has stable field names and order and round-trips every record.</summary>
    [Fact]
    public void JsonHasAStableShapeAndRoundTrips()
    {
        var limits = MathBlockLimits.Resolve();
        using var stream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(stream))
            MathBlockLimits.WriteJson(writer, limits);

        using var document = JsonDocument.Parse(stream.ToArray());
        var array = document.RootElement;

        Assert.Equal(JsonValueKind.Array, array.ValueKind);
        Assert.Equal(limits.Count, array.GetArrayLength());
        for (var index = 0; index < limits.Count; index++)
        {
            var element = array[index];
            var limit = limits[index];
            Assert.Equal(JsonFields, element.EnumerateObject().Select(property => property.Name), StringComparer.Ordinal);
            Assert.Equal(limit.Name, element.GetProperty("name").GetString());
            Assert.Equal(limit.Operation, element.GetProperty("operation").GetString());
            Assert.Equal(limit.Kind, Enum.Parse<MathBlockLimitKind>(element.GetProperty("kind").GetString()!));
            Assert.Equal(limit.Device, Enum.Parse<MathBlockLimitDevice>(element.GetProperty("device").GetString()!));
            Assert.Equal(limit.Minimum, ReadNumber(element, "minimum"));
            Assert.Equal(limit.Maximum, ReadNumber(element, "maximum"));
            Assert.Equal(limit.Value, ReadNumber(element, "value"));
            Assert.Equal(limit.Unit, element.GetProperty("unit").GetString());
            Assert.Equal(limit.Option, element.GetProperty("option").GetString());
            Assert.Equal(limit.DrivenBy, element.GetProperty("drivenBy").EnumerateArray().Select(driver => driver.GetString()!), StringComparer.Ordinal);
            Assert.Equal(limit.Rule, element.GetProperty("rule").GetString());
        }

        using var again = new MemoryStream();
        using (var writer = new Utf8JsonWriter(again))
            MathBlockLimits.WriteJson(writer, MathBlockLimits.Resolve());
        Assert.Equal(stream.ToArray(), again.ToArray());
    }

    /// <summary>Verifies the JSON of an empty list and a null argument.</summary>
    [Fact]
    public void JsonHandlesAnEmptyListAndRejectsNull()
    {
        using var stream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(stream))
            MathBlockLimits.WriteJson(writer, []);

        Assert.Equal("[]", System.Text.Encoding.UTF8.GetString(stream.ToArray()));
        Assert.Throws<ArgumentNullException>(() => MathBlockLimits.WriteJson(null!, []));
    }

    private static bool Named(MathBlockLimit limit, string name) =>
        string.Equals(limit.Name, name, StringComparison.Ordinal);

    private static bool Is(MathBlockLimit limit, string name, string? operation) =>
        Named(limit, name) && string.Equals(limit.Operation, operation, StringComparison.Ordinal);

    private static long? Width(List<MathBlockLimit> widths, string form) =>
        widths.Single(limit => string.Equals(limit.Operation, form, StringComparison.Ordinal)).Value;

    private static long? ReadNumber(JsonElement element, string name)
    {
        var property = element.GetProperty(name);
        return property.ValueKind == JsonValueKind.Null ? null : property.GetInt64();
    }
}
