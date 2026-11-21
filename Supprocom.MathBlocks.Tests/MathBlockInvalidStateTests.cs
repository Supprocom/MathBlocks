using System.Globalization;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies that out-of-domain inputs give an invalid value of the declared type instead of an exception.</summary>
/// <remarks>
/// <see cref="MathBlockOperation.Evaluate(IReadOnlyList{MathBlockValue})"/> throws when an evaluator returns a type
/// that its declared output type does not accept. An invalid result built from a bare kind such as
/// <c>MathBlockType.Vector()</c> has no length, so it is rejected whenever the declared type knows the length; an
/// empty vector's type has no length either, so a resolver cannot reject it beside a longer vector.
/// </remarks>
public sealed class MathBlockInvalidStateTests
{
    private static readonly Dictionary<string, (string Identity, Func<MathBlockValue[]> Inputs)> Cases =
        new(StringComparer.Ordinal)
        {
            // Invalid results built from a type with no shape or the wrong unit.
            ["complex-matrix.pick/empty-nodes"] = ("complex-matrix.pick@1", () => [ComplexVector(), ComplexVector(new Complex(0.5f, 0f))]),
            ["extension.mcshane/empty-points"] = ("extension.mcshane@1", () => [Vector(), Vector(0f, 2f), Vector(1f), Scalar(1f)]),
            ["extension.whitney/empty-points"] = ("extension.whitney@1", () => [Vector(), Vector(0f, 2f), Vector(1f), Scalar(1f)]),
            ["geometry.delaunay-graph/one-point"] = ("geometry.delaunay-graph@1", () => [Points((0f, 0f))]),
            ["geometry.gabriel-graph/one-point"] = ("geometry.gabriel-graph@1", () => [Points((0f, 0f))]),
            ["graph.hodge-potential/no-edges"] = ("graph.hodge-potential@1", () => [MathBlockValue.Graph(new MathBlockGraph(3, []))]),
            ["matrix.column/index-outside"] = ("matrix.column@1", () => [Matrix(1, 1, 2f), Scalar(1f)]),
            ["matrix.row/index-outside"] = ("matrix.row@1", () => [Matrix(1, 1, 2f), Scalar(1f)]),
            ["matrix.hankel/empty-boundary"] = ("matrix.hankel@1", () => [Vector(), Vector(2f, 3f, 4f)]),
            ["matrix.toeplitz/empty-boundary"] = ("matrix.toeplitz@1", () => [Vector(), Vector(1f, 3f, 4f)]),
            ["matrix.solve/singular"] = ("matrix.solve@1", () => [Matrix(2, 2, 0f, 0f, 0f, 0f), Vector(4f, 8f)]),
            ["matrix.symmetric-eigenvalues/not-symmetric"] = ("matrix.symmetric-eigenvalues@1", () => [Matrix(2, 2, 1f, 2f, 3f, 4f)]),
            ["matrix.maximal-minors/too-many-columns-with-unit"] = ("matrix.maximal-minors@1", () => [MathBlockValue.Matrix(new MathBlockMatrix(1, 21, Enumerable.Range(1, 21).Select(value => (float)value)), MathBlockUnit.Basis0)]),
            ["path.hysteresis/equal-thresholds"] = ("path.hysteresis@1", () => [Vector(-2f, 0f, 2f, 0f, -2f), Scalar(1f), Scalar(1f)]),
            ["survival.discrete-hazard/not-a-distribution"] = ("survival.discrete-hazard@1", () => [Vector(0f)]),
            ["survival.product-limit/empty-events"] = ("survival.product-limit@1", () => [Vector(), Vector(4f, 3f)]),
            ["transport.minimum-assignment/too-large"] = ("transport.minimum-assignment@1", () => [MathBlockValue.Matrix(new MathBlockMatrix(21, 21, Enumerable.Range(0, 441).Select(value => (float)(value % 7))))]),
            ["transport.monotone-coupling/empty-source"] = ("transport.monotone-coupling@1", () => [Vector(), Vector(0.5f, 0.5f)]),
            ["vector.gather/index-outside"] = ("vector.gather@1", () => [Vector(), Vector(3f, 1f)]),
            ["transform.haar/not-a-power-of-two"] = ("transform.haar@1", () => [Vector(1f, 2f, 3f)]),
            ["transport.assignment-cost/non-integer-index"] = ("transport.assignment-cost@1", () => [Matrix(2, 2, 3f, 1f, 1f, 3f), Vector(0.5f, 1f)]),

            // An empty vector beside a longer one: the result was a valid value of the wrong length.
            ["vector.add/empty-left"] = ("vector.add@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["vector.subtract/empty-left"] = ("vector.subtract@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["vector.multiply/empty-left"] = ("vector.multiply@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["vector.divide/empty-left"] = ("vector.divide@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["vector.equal/empty-left"] = ("vector.equal@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["vector.greater-than/empty-left"] = ("vector.greater-than@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["vector.less-than/empty-left"] = ("vector.less-than@1", () => [Vector(), Vector(4f, 3f, 2f, 1f)]),
            ["boolean-vector.and/empty-left"] = ("boolean-vector.and@1", () => [Booleans(), Booleans(true, false, true)]),
            ["boolean-vector.or/empty-left"] = ("boolean-vector.or@1", () => [Booleans(), Booleans(true, false, true)]),
            ["boolean-vector.xor/empty-left"] = ("boolean-vector.xor@1", () => [Booleans(), Booleans(true, false, true)]),
            ["vector.select/empty-mask"] = ("vector.select@1", () => [Booleans(), Vector(1f, 2f), Vector(3f, 4f)]),
            ["complex-vector.create/empty-real"] = ("complex-vector.create@1", () => [Vector(), Vector(2f, 4f)]),
            ["matrix.stack-rows/empty-first"] = ("matrix.stack-rows@1", () => [Vector(), Vector(3f, 4f)]),

            // Results that overflow, which threw from the point and graph-edge validation.
            ["geometry.centroid/overflow"] = ("geometry.centroid@1", () => [Points((3.38e38f, 0f), (3.38e38f, 0f))]),
            ["geometry.delaunay-graph/overflow"] = ("geometry.delaunay-graph@1", () => [Points((0f, 0f), (1e25f, 0f), (0f, 1e25f))]),
            ["geometry.gabriel-graph/overflow"] = ("geometry.gabriel-graph@1", () => [Points((0f, 0f), (1e25f, 0f), (0f, 1e25f))]),
            ["topology.zero-dimensional-persistence/overflow"] = ("topology.zero-dimensional-persistence@1", () => [Points((0f, 0f), (1e25f, 0f), (0f, 1e25f))]),

            // An intermediate that overflows makes the result invalid. A variance, a standard-deviation product or a distance moment
            // that is infinity used to divide a finite value and give a valid zero (or a valid near-zero) where the true value is not zero.
            ["statistics.pearson-correlation/variance-overflow"] = ("statistics.pearson-correlation@1", () =>
                [Vector(1f, 2f, 3f, 4f), Vector(-7.143571252424402f, 3.4e38f, 7.274205695928337f, -9.877113669855383f)]),
            ["statistics.distance-correlation/moment-overflow"] = ("statistics.distance-correlation@1", () =>
                [Vector(-6.21e37f, -6.343768537094183f, -5.8364683556946435f), Vector(-5.71e-37f, 36.84280271658108f, 0.9048608060071095f)]),
            ["statistics.linear-slope/variance-overflow"] = ("statistics.linear-slope@1", () =>
                [Vector(7.114245152862294f, -6.21e37f, -728.0038665276926f, 4.224291341469105f), Vector(0.4953195529423522f, 0.7783700051634825f, 118f, -720.3804674671959f)]),
            ["statistics.linear-intercept/variance-overflow"] = ("statistics.linear-intercept@1", () =>
                [Vector(7.114245152862294f, -6.21e37f, -728.0038665276926f, 4.224291341469105f), Vector(0.4953195529423522f, 0.7783700051634825f, 118f, -720.3804674671959f)]),
            ["statistics.linear-r-squared/variance-overflow"] = ("statistics.linear-r-squared@1", () =>
                [Vector(1.4e-45f, -1.58e-37f, -17.27875959474386f, -0.8325065752238905f), Vector(-3.496470870518605f, -11.96980468906019f, 9.27e37f, -729.5969940812662f)]),
            ["statistics.autocorrelation/variance-overflow"] = ("statistics.autocorrelation@1", () =>
                [Vector(1.2e38f, -4.440892098500626e-16f, -22.450293565523026f, 0.0037950201825623286f), Scalar(2f)]),
            ["vector.standardize/variance-overflow"] = ("vector.standardize@1", () =>
                [Vector(3.4e38f, -9.05e29f, 710.0904103212077f)]),
            ["geometry.simplicial-depth/coordinate-overflow"] = ("geometry.simplicial-depth@1", () =>
                [Points((698.0421626654253f, 0.7817012842080717f), (-22.194671885609296f, 3.4e38f), (-3.80572792044629f, -708.0863943344233f)),
                    Points((-0.9999999999999934f, 7.274205695928337f))]),
            ["geometry.barycentric-coordinates/denominator-overflow"] = ("geometry.barycentric-coordinates@1", () =>
                [Points((1f, 1f)), Points((1e25f, 0f), (0f, 1e25f), (0f, 0f))]),
            ["geometry.halfspace-depth/nan-cross-product"] = ("geometry.halfspace-depth@1", () =>
                [Points((1e25f, 1e25f), (1.09e25f, 1.09e25f)), Points((0f, 0f))]),

            // A NaN operand gives NaN from the owned Max and Min (IEEE 754-2019), so an intermediate that is NaN makes the result invalid.
            // A zero peak followed by a zero is 0 / 0 (as a zero peak followed by a negative value is already invalid).
            ["path.maximum-relative-decline/zero-peak-then-zero"] = ("path.maximum-relative-decline@1", () => [Vector(0f, -0f, 0.5f)]),
            ["path.maximum-relative-decline/zero-peak-then-later-decline"] = ("path.maximum-relative-decline@1", () => [Vector(0f, 0f, 3f, 1f)]),
            // A zero Lipschitz constant times an overflowing distance is 0 * infinity.
            ["extension.mcshane/zero-lipschitz-overflowing-distance"] = ("extension.mcshane@1", () =>
                [Vector(-3.38e38f, 0f), Vector(-5f, 3f), Vector(3.38e38f), Scalar(0f)]),
            ["extension.whitney/zero-lipschitz-overflowing-distance"] = ("extension.whitney@1", () =>
                [Vector(-3.38e38f, 0f), Vector(5f, -3f), Vector(3.38e38f), Scalar(0f)]),

            // The remaining overflow victims: a division by an infinity (a squared divisor, a slope's difference), a NaN cross product and a trace
            // beyond ln(DBL_MAX) + ln(n) / 2 (the scaling and squaring of dense#596 collapsed to valid zeros without a non-finite value).
            ["complex.divide/divisor-overflow"] = ("complex.divide@1", () =>
                [MathBlockValue.Complex(new Complex(1f, 1f)), MathBlockValue.Complex(new Complex(1e25f, 1e25f))]),
            ["geometry.contains-point/crossing-overflow"] = ("geometry.contains-point@1", () =>
                [Points((-1e25f, -1e25f), (1e25f, -1e25f), (1e25f, 1e25f)), Points((8.18e24f, 7.5e24f))]),
            ["geometry.convex-hull/nan-cross-product"] = ("geometry.convex-hull@1", () =>
                [Points((0f, 0f), (1e25f, 1e25f), (1.09e25f, 1.09e25f))]),
            ["statistics.theil-sen-slope/difference-overflow"] = ("statistics.theil-sen-slope@1", () =>
                [Vector(-3.38e38f, 3.38e38f), Vector(1f, 2f)]),
            ["matrix.exponential/trace-overflow"] = ("matrix.exponential@1", () =>
                [Matrix(2, 2, 1.56e25f, -4.8e12f, 5.52e37f, -1.0737128770591469f)]),

            // The squared energy distance is NaN (inf - inf of overflowing pairwise means): CoreCLR's owned maximum propagates it.
            ["transport.energy-distance/nan-squared"] = ("transport.energy-distance@1", () => [Vector(-3.38e38f, 3.38e38f), Vector(0f, 0f)]),

            // A row norm that overflows asked for int.MaxValue squarings.
            ["matrix.exponential/overflowing-norm"] = ("matrix.exponential@1", () => [Matrix(2, 2, 3.38e38f, 3.38e38f, 0f, 0f)]),

            // An iteration count above 10,000, which graph.page-rank and transport.sinkhorn-coupling already reject;
            // 1e9 iterations ran for minutes.
            ["markov.stationary-distribution/iterations-over-cap"] = ("markov.stationary-distribution@1", () => IterativeInputs("markov.stationary-distribution@1", 10_001f)),
            ["matrix.perron-value/iterations-over-cap"] = ("matrix.perron-value@1", () => IterativeInputs("matrix.perron-value@1", 10_001f)),
            ["matrix.perron-vector/iterations-over-cap"] = ("matrix.perron-vector@1", () => IterativeInputs("matrix.perron-vector@1", 10_001f)),
            ["matrix.spectral-norm/iterations-over-cap"] = ("matrix.spectral-norm@1", () => IterativeInputs("matrix.spectral-norm@1", 10_001f)),

            // A square in the Gram matrix overflows: the owned Max dropped the NaN from the eigenvalue step and returned a valid 0,
            // where vector.l2-norm and matrix.frobenius-norm give an invalid value when their sum of squares overflows.
            ["matrix.spectral-norm/gram-overflow-2x2"] = ("matrix.spectral-norm@1", () => [Matrix(2, 2, 21.808109993025802f, -1E-16f, 2.0261677264706863f, 3.4e38f), Scalar(32f)]),
            ["matrix.spectral-norm/gram-overflow-5x5"] = ("matrix.spectral-norm@1", () => [Matrix(5, 5, -1.4934540366773823f, -724.1384810885675f, -110f, -2.03e31f, -736.1104387680798f, -4.29484363142549f, 8.33e27f, 4.722841828411625f, 0.09556606759165165f, -39f, 0.04059996335593041f, -0.5318688056945957f, 8.84e21f, -740.769435392698f, -20.097659664810053f, -739.8147664805746f, 0.9999956274522844f, 2.7099982004438914f, 4.192299232855897f, -4.39e22f, 3.6241968239171687f, 3.82e27f, -750.0798031522245f, 59.5f, -5.7572465458520234f), Scalar(32f)])
        };

    /// <summary>Gets the operations whose second input is an iteration count capped at 10,000.</summary>
    public static TheoryData<string> CappedIterationIdentities =>
        ["markov.stationary-distribution@1", "matrix.perron-value@1", "matrix.perron-vector@1", "matrix.spectral-norm@1"];

    private static readonly float[] ScalarVariants =
        [0f, -0f, -1f, 1f, 2f, 0.5f, -0.5f, 3f, 21f, 65537f, 3.16e38f, -3.16e38f, 5.28e-41f, 4097f, 1_000_001f];

    // Operations whose result shape is not a function of the input types, so their declared type leaves it out.
    private static readonly Dictionary<string, string> UndeclaredShapes = new(StringComparer.Ordinal)
    {
        // CUDA sizes this result by an upper bound, C(columns, min(rows, columns / 2)), not the exact count
        // C(columns, rows), so no declared length would equal its slot shape for every matrix shape.
        ["matrix.maximal-minors@1"] = "the minor count is C(columns, rows), which the resolver does not compute",
        ["geometry.convex-hull@1"] = "the number of hull vertices depends on the points, not on their count"
    };

    /// <summary>Gets the out-of-domain case names.</summary>
    public static TheoryData<string> CaseNames => [.. Cases.Keys.Order(StringComparer.Ordinal)];

    /// <summary>Verifies one out-of-domain case gives an invalid value of the declared type.</summary>
    [Theory]
    [MemberData(nameof(CaseNames))]
    [Trait("Category", "InvalidState")]
    public async Task OutOfDomainInputsGiveAnInvalidValueOfTheDeclaredType(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        var (identity, create) = Cases[name];
        var operation = Find(identity);
        var inputs = create();
        var declared = operation.ResolveOutputType(inputs.Select(input => input.Type).ToArray());

        // matrix.exponential used to run for int.MaxValue squarings here; the time limit turns that into a failure.
        var result = await Task.Run(() => operation.Evaluate(inputs)).WaitAsync(TimeSpan.FromSeconds(60));

        Assert.False(result.IsValid, $"{name} returned a valid {result.Type}.");
        Assert.Equal(declared, result.Type);
    }

    /// <summary>Verifies an iteration count of exactly 10,000 still gives a valid result.</summary>
    [Theory]
    [MemberData(nameof(CappedIterationIdentities))]
    [Trait("Category", "InvalidState")]
    public void IterationCountsUpToTheCapGiveAValidResult(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var result = Find(identity).Evaluate(IterativeInputs(identity, 10_000f));

        Assert.True(result.IsValid, $"{identity} returned {result.InvalidReason}");
    }

    // The operation's first regression case with its iteration count (the second input) replaced.
    private static MathBlockValue[] IterativeInputs(string identity, float iterations)
    {
        var inputs = Find(identity).RegressionCases[0].Inputs.ToArray();
        inputs[1] = MathBlockValue.Scalar(iterations, inputs[1].Type.Unit);
        return inputs;
    }

    /// <summary>
    /// Verifies each operation with an out-of-domain case declares the shape of its valid results, so an invalid
    /// value built from the declared type carries the shape a valid result would have (as the CUDA result type does).
    /// </summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void OperationsWithOutOfDomainCasesDeclareTheShapeOfTheirValidResults()
    {
        var failures = new List<string>();
        foreach (var identity in Cases.Values.Select(item => item.Identity).Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal))
        {
            if (UndeclaredShapes.ContainsKey(identity))
                continue;
            var operation = Find(identity);
            foreach (var regression in operation.RegressionCases)
            {
                var declared = operation.ResolveOutputType(regression.Inputs.Select(input => input.Type).ToArray());
                var result = operation.Evaluate(regression.Inputs);
                if (!result.IsValid || declared != result.Type)
                    failures.Add($"{identity}/{regression.Name}: declared {declared}, result {result.Type} ({(result.IsValid ? "valid" : result.InvalidReason)})");
            }
        }
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>
    /// Verifies a window whose running peak is 0 followed by 0 (0 / 0) is invalid in both window forms, as a zero peak followed by a
    /// negative value is; the windows with a positive peak are valid.
    /// </summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void RelativeDeclineWindowsWithAZeroPeakFollowedByZeroAreInvalid()
    {
        var series = Vector(-0f, 2f, 0f, -0f, 0f, 1.25f);
        var validity = MathBlockCatalog.Standard.Get("window-valid.path.maximum-relative-decline").Evaluate(series, Scalar(3f));
        Assert.Equal([false, false, true, true, false, false], validity.AsBooleanVector());
        var form = MathBlockCatalog.Standard.Get("window.path.maximum-relative-decline").Evaluate(series, Scalar(3f), Scalar(-1f));
        Assert.Equal([-1f, -1f, 1f, 1f, -1f, -1f], form.AsVector());
    }

    /// <summary>
    /// Verifies the trace bound of matrix.exponential: the result is invalid when trace / n exceeds the logarithm of the largest finite value + ln(n) / 2 (the Hadamard form; the
    /// bound with ln(n) is also valid and stricter) and a trace below it still gives a valid result.
    /// </summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void MatrixExponentialIsInvalidAboveTheTraceBoundAndValidBelowIt()
    {
        var operation = MathBlockCatalog.Standard.Get("matrix.exponential");
        Assert.True(operation.Evaluate(Matrix(2, 2, 80f, 0f, 0f, 0f)).IsValid);
        Assert.True(operation.Evaluate(Matrix(2, 2, 1.0f, 0f, 0f, 1f)).IsValid);
        Assert.False(operation.Evaluate(Matrix(2, 2, 200f, 0f, 0f, 0f)).IsValid);
        Assert.False(operation.Evaluate(Matrix(2, 2, 1.56e25f, -4.8e12f, 5.52e37f, -1.0737128770591469f)).IsValid);
    }

    /// <summary>Verifies the sign of a zero tie in a max-plus and a min-plus product is the owned maximum's and minimum's.</summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void TropicalProductsKeepTheSignOfAZeroTieOfTheOwnedMaximumAndMinimum()
    {
        var maximum = MathBlockCatalog.Standard.Get("tropical.max-plus-multiply").Evaluate(Matrix(1, 2, 0f, -0f), Matrix(2, 1, 0f, -0f));
        Assert.Equal(0L, BitConverter.SingleToInt32Bits(maximum.AsMatrix()[0, 0]));
        var minimum = MathBlockCatalog.Standard.Get("tropical.min-plus-multiply").Evaluate(Matrix(1, 2, -0f, 0f), Matrix(2, 1, -0f, 0f));
        Assert.Equal(int.MinValue, BitConverter.SingleToInt32Bits(minimum.AsMatrix()[0, 0]));
    }

    /// <summary>Verifies the rolling variance is in the square of the input unit.</summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void RollingVarianceIsInTheSquareOfTheInputUnit()
    {
        var operation = MathBlockCatalog.Standard.Get("sequence.rolling-variance");
        var unit = MathBlockUnit.Basis0;
        MathBlockValue[] inputs = [MathBlockValue.Vector([1f, 2f, 4f, 8f], unit), Scalar(2f)];
        var squared = unit.Pow(new MathRational(2));

        Assert.Equal(squared, operation.ResolveOutputType(inputs.Select(input => input.Type).ToArray()).Unit);
        var result = operation.Evaluate(inputs);
        Assert.True(result.IsValid);
        Assert.Equal(squared, result.Type.Unit);
        var tooWide = operation.Evaluate(MathBlockValue.Vector([1f, 2f], unit), Scalar(3f));
        Assert.False(tooWide.IsValid);
        Assert.Equal(squared, tooWide.Type.Unit);
    }

    /// <summary>
    /// Evaluates every operation of the standard, window and elementwise registries on its samples with inputs
    /// replaced by out-of-domain values, and requires a value of a type its declared type accepts whenever the type
    /// resolves, and an invalid value of exactly the declared type: an exception from Evaluate past type resolution
    /// is a failure.
    /// </summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void EveryOperationReturnsAValueForOutOfDomainInputs()
    {
        var operations = MathBlockCatalog.Standard.Operations;
        var failures = new SortedDictionary<string, string>(StringComparer.Ordinal);
        var evaluations = 0;
        foreach (var operation in operations)
        {
            foreach (var inputs in Variants(operation))
            {
                MathBlockType declared;
                try
                {
                    declared = operation.ResolveOutputType(inputs.Select(input => input.Type).ToArray());
                }
                catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
                {
                    continue;
                }
                evaluations++;
                try
                {
                    var result = operation.Evaluate(inputs);
                    if (!declared.Accepts(result.Type))
                        failures.TryAdd(operation.Identity, $"returned {result.Type} for the declared {declared}");
                    else if (!result.IsValid && result.Type != declared)
                        failures.TryAdd(operation.Identity, $"returned an invalid {result.Type}, not the declared {declared} ({Describe(inputs)})");
                }
                catch (Exception exception) when (exception is not OutOfMemoryException)
                {
                    failures.TryAdd(operation.Identity, $"{exception.GetType().Name}: {exception.Message} ({Describe(inputs)})");
                }
            }
        }

        Assert.True(evaluations > 10_000, $"Only {evaluations} evaluations ran.");
        Assert.True(
            failures.Count == 0,
            string.Create(CultureInfo.InvariantCulture, $"{failures.Count} operation(s) threw:{Environment.NewLine}{string.Join(Environment.NewLine, failures.Select(item => $"{item.Key}: {item.Value}"))}"));
    }

    private static MathBlockOperation Find(string identity)
    {
        var separator = identity.LastIndexOf('@');
        var identifier = identity[..separator];
        var version = int.Parse(identity[(separator + 1)..], CultureInfo.InvariantCulture);
        return MathBlockCatalog.Standard.Get(identifier, version);
    }

    // Each sample (the performance case and every regression case), the sample with every input in one unit, and
    // the sample with one input at a time in a unit; for each, every input replaced by each of its kind's variants,
    // then every input replaced by its variant of the same index.
    private static IEnumerable<MathBlockValue[]> Variants(MathBlockOperation operation)
    {
        var samples = new List<MathBlockValue[]> { operation.PerformanceCase.Inputs.ToArray() };
        samples.AddRange(operation.RegressionCases.Select(item => item.Inputs.ToArray()));
        var plain = samples.Count;
        for (var index = 0; index < plain; index++)
        {
            samples.Add(samples[index].Select(value => WithUnit(value, MathBlockUnit.Basis0)).ToArray());
            for (var input = 0; input < samples[index].Length; input++)
            {
                var single = (MathBlockValue[])samples[index].Clone();
                single[input] = WithUnit(single[input], MathBlockUnit.Basis1);
                samples.Add(single);
            }
        }
        for (var index = 0; index < samples.Count; index++)
        {
            var sample = samples[index];
            yield return sample;
            var alternatives = sample.Select(Alternatives).ToArray();
            for (var input = 0; input < sample.Length; input++)
                for (var variant = 0; variant < alternatives[input].Count; variant++)
                {
                    var inputs = (MathBlockValue[])sample.Clone();
                    inputs[input] = alternatives[input][variant];
                    yield return inputs;
                }
            var widest = alternatives.Max(list => list.Count);
            for (var variant = 0; variant < widest; variant++)
            {
                var inputs = new MathBlockValue[sample.Length];
                for (var input = 0; input < sample.Length; input++)
                    inputs[input] = alternatives[input].Count == 0 ? sample[input] : alternatives[input][variant % alternatives[input].Count];
                yield return inputs;
            }
        }
    }

    private static List<MathBlockValue> Alternatives(MathBlockValue value)
    {
        var list = new List<MathBlockValue>();
        if (!value.IsValid)
            return list;
        var unit = value.Type.Unit;
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                list.AddRange(ScalarVariants.Select(item => MathBlockValue.Scalar(item, unit)));
                break;
            case MathBlockValueKind.Boolean:
                list.Add(MathBlockValue.Boolean(!value.AsBoolean()));
                break;
            case MathBlockValueKind.Complex:
                list.Add(MathBlockValue.Complex(new Complex(0f, 0f), unit));
                list.Add(MathBlockValue.Complex(new Complex(3.38e38f, 3.38e38f), unit));
                break;
            case MathBlockValueKind.Vector:
                {
                    var values = value.AsVector().ToArray();
                    var count = values.Length;
                    list.Add(MathBlockValue.Vector([], unit));
                    list.Add(MathBlockValue.Vector([0f], unit));
                    list.Add(MathBlockValue.Vector(new float[count], unit));
                    list.Add(MathBlockValue.Vector(values.Select(item => -item - 1f), unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Repeat(1f, count), unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Repeat(3.16e38f, count), unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Range(0, Math.Max(count, 2)).Select(item => item % 2 == 0 ? 3.38e38f : -3.38e38f), unit));
                    list.Add(MathBlockValue.Vector(values.Select(item => item + 0.5f), unit));
                    list.Add(MathBlockValue.Vector([.. values, count == 0 ? 1f : values[^1]], unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Range(0, 7).Select(item => (float)item), unit));
                    break;
                }
            case MathBlockValueKind.BooleanVector:
                {
                    var values = value.AsBooleanVector().ToArray();
                    list.Add(MathBlockValue.BooleanVector([]));
                    list.Add(MathBlockValue.BooleanVector(new bool[values.Length]));
                    list.Add(MathBlockValue.BooleanVector([.. values, true]));
                    break;
                }
            case MathBlockValueKind.Matrix:
                {
                    var matrix = value.AsMatrix();
                    var entries = matrix.ToArray();
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, new float[entries.Length]), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, entries.Select((_, index) => index % 2 == 0 ? 3.38e38f : -3.38e38f)), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Repeat(3.16e38f, entries.Length)), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(1, 1, [2f]), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(2, 3, [1f, 2f, 3f, 4f, 5f, 6f]), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1f, 1f, 1f, 1f]), unit));
                    break;
                }
            case MathBlockValueKind.ComplexVector:
                {
                    var count = value.AsComplexVector().Count;
                    list.Add(MathBlockValue.ComplexVector([], unit));
                    list.Add(MathBlockValue.ComplexVector(new Complex[count], unit));
                    list.Add(MathBlockValue.ComplexVector(Enumerable.Repeat(new Complex(3.38e38f, 3.38e38f), Math.Max(count, 1)), unit));
                    break;
                }
            case MathBlockValueKind.PointSet:
                {
                    var count = value.AsPointSet().Count;
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet([]), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet([new MathBlockPoint(0f, 0f)]), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Repeat(new MathBlockPoint(1f, 1f), count)), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, count).Select(index => new MathBlockPoint(index * 1e25f, (index % 2) * 1e25f))), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, count).Select(index => new MathBlockPoint(index % 2 == 0 ? 3.38e38f : -3.38e38f, index % 3 == 0 ? -3.38e38f : 3.38e38f))), unit));
                    break;
                }
            case MathBlockValueKind.Graph:
                {
                    var graph = value.AsGraph();
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(1, []), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, []), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, graph.Select(edge => edge with { Weight = -edge.Weight - 1f })), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, graph.Select(edge => edge with { Weight = 3.16e38f })), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount + 1, graph), unit));
                    break;
                }
        }
        return list;
    }

    private static MathBlockValue WithUnit(MathBlockValue value, MathBlockUnit unit)
    {
        if (!value.IsValid)
            return value;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar => MathBlockValue.Scalar(value.AsScalar(), unit),
            MathBlockValueKind.Complex => MathBlockValue.Complex(value.AsComplex(), unit),
            MathBlockValueKind.Vector => MathBlockValue.Vector(value.AsVector(), unit),
            MathBlockValueKind.Matrix => MathBlockValue.Matrix(value.AsMatrix(), unit),
            MathBlockValueKind.ComplexVector => MathBlockValue.ComplexVector(value.AsComplexVector(), unit),
            MathBlockValueKind.ComplexMatrix => MathBlockValue.ComplexMatrix(value.AsComplexMatrix(), unit),
            MathBlockValueKind.PointSet => MathBlockValue.PointSet(value.AsPointSet(), unit),
            MathBlockValueKind.Graph => MathBlockValue.Graph(value.AsGraph(), unit),
            MathBlockValueKind.RunSet => MathBlockValue.RunSet(value.AsRunSet(), unit),
            _ => value
        };
    }

    private static string Describe(MathBlockValue[] inputs) =>
        string.Join(", ", inputs.Select(input => input.IsValid && input.Type.Kind == MathBlockValueKind.Scalar
            ? input.AsScalar().ToString("R", CultureInfo.InvariantCulture)
            : input.Type.ToString()));

    private static MathBlockValue Scalar(float value) => MathBlockValue.Scalar(value);

    private static MathBlockValue Vector(params float[] values) => MathBlockValue.Vector(values);

    private static MathBlockValue Booleans(params bool[] values) => MathBlockValue.BooleanVector(values);

    private static MathBlockValue ComplexVector(params Complex[] values) => MathBlockValue.ComplexVector(values);

    private static MathBlockValue Matrix(int rows, int columns, params float[] values) =>
        MathBlockValue.Matrix(new MathBlockMatrix(rows, columns, values));

    private static MathBlockValue Points(params (float X, float Y)[] points) =>
        MathBlockValue.PointSet(new MathBlockPointSet(points.Select(point => new MathBlockPoint(point.X, point.Y))));
}
