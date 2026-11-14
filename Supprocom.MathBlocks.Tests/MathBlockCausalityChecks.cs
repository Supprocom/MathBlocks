using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks an operation's causality label against its CoreCLR evaluator on seeded random inputs.</summary>
/// <remarks>
/// Vector-kind inputs are generated from a domain found per input; every other input keeps the operation's
/// performance-case value, except the width input of a Trailing label, which takes each tested width. Output rows are
/// matched to input rows by the row mapping documented on <see cref="MathBlockCausality"/>.
/// A Pointwise, Trailing or Expanding label is also swept over its regression inputs in two value regimes: the full
/// run at several lengths is compared with every prefix, in value and in validity.
/// </remarks>
internal static class MathBlockCausalityChecks
{
    private const int SeedCount = 3;
    private const int RowsPerCase = 6;
    private const int ReverseTrials = 24;
    private static readonly int[] Lengths = [5, 8, 13, 16, 21];

    private static readonly Domain[] VectorDomains =
    [
        Domain.Real, Domain.Positive, Domain.Unit, Domain.SmallMass, Domain.Count, Domain.Index, Domain.Integer,
        Domain.Probability
    ];

    private const int SweepSeeds = 2;
    private const int SweepCombinationsPerRegime = 2;
    private const int SweepOwnLengthLimit = 40;
    private static readonly int[] SweepLengths = [1, 2, 3, 4, 5, 7, 8, 12, 17, 24, 33];
    private static readonly int[] SweepProbeLengths = [8, 17, 33];

    // Value regimes of the sweep: small positive and structured rows, and mixed-sign or large rows.
    private static readonly Domain[] FirstRegimeDomains =
        [Domain.Positive, Domain.Unit, Domain.Probability, Domain.SmallMass, Domain.Count, Domain.Index, Domain.Sorted];
    private static readonly Domain[] SecondRegimeDomains =
        [Domain.Real, Domain.LargeReal, Domain.Integer, Domain.LargePositive];

    // Labelled Expanding although the call is valid only once the prefix holds as many rows as the width or lag in
    // input 1 (a Trailing label would say so, and sequence.difference omits lag rows, not lag - 1). Every row that
    // exists matches the full run, so these are not look-ahead. A later item relabels or documents them.
    private static readonly Dictionary<string, string> WarmUpExemptions = new(StringComparer.Ordinal)
    {
        ["sequence.rolling-sum@1"] = "valid only from a prefix of width rows",
        ["sequence.rolling-mean@1"] = "valid only from a prefix of width rows",
        ["sequence.difference@1"] = "valid only from a prefix of lag + 1 rows"
    };

    // The input must be a whole probability distribution, which leaves no second value regime.
    private static readonly HashSet<string> SingleRegimeOperations = new(StringComparer.Ordinal)
    {
        "survival.discrete-hazard@1"
    };

    private static readonly Domain[] VectorDomainsWithWhole =
    [
        Domain.Real, Domain.Positive, Domain.Unit, Domain.SmallMass, Domain.Count, Domain.Index, Domain.Integer,
        Domain.Sorted, Domain.Probability
    ];

    public enum Domain
    {
        Real,
        Positive,
        Unit,
        SmallMass,
        Count,
        Index,
        Integer,
        Sorted,
        Probability,
        Boolean,
        Complex,
        LargeReal,
        LargePositive,
        BooleanMostlyTrue,
        ComplexLarge
    }

    /// <summary>Returns every way the operation's evaluator contradicts its label; empty when the label holds.</summary>
    public static List<string> Check(MathBlockOperation operation)
    {
        ArgumentNullException.ThrowIfNull(operation);
        var failures = new List<string>();
        var context = new Context(operation, failures);
        var kind = operation.Causality.Kind;
        if (kind == MathBlockCausality.NotSeries)
        {
            if (context.SeriesInputs.Length != 0)
                context.Fail("is NotSeries but has a vector-kind input");
            return failures;
        }
        if (context.SeriesInputs.Length == 0)
        {
            context.Fail($"is {kind} but has no vector-kind input");
            return failures;
        }
        if (kind is MathBlockCausality.Pointwise or MathBlockCausality.Trailing or MathBlockCausality.Expanding)
            CheckCausal(context);
        else
            CheckNonCausal(context);
        return failures;
    }

    private static void CheckCausal(Context context)
    {
        var plan = FindPlan(context, VectorDomains, requirePerturbableRows: true, minimumLengths: 2);
        if (plan is null)
        {
            context.Fail("has no valid row-independent input domain on two or more tested lengths");
            return;
        }

        var kind = context.Operation.Causality.Kind;
        foreach (var length in plan.Lengths)
            foreach (var width in context.Widths(length))
                for (var seed = 0; seed < SeedCount; seed++)
                {
                    var random = new Random(Seed(context.Operation.Identity, length, width, seed));
                    var inputs = plan.Generate(random, length);
                    var baseline = context.Evaluate(inputs, width);
                    if (!baseline.IsValid || !IsSeriesKind(baseline.Type.Kind))
                    {
                        context.Fail($"returned {Describe(baseline)} at n={length}, w={width}, seed={seed}");
                        return;
                    }
                    var outputLength = SeriesLength(baseline);
                    if (kind == MathBlockCausality.Trailing && outputLength != length &&
                        length - outputLength != context.Operation.Causality.WarmUpRows(width))
                    {
                        context.Fail($"returned {outputLength} rows for n={length}, w={width}, which matches neither n nor n - WarmUpRows(w)");
                        return;
                    }
                    foreach (var outputRow in PickRows(random, outputLength))
                    {
                        var inputRow = InputRow(outputRow, length, outputLength);
                        var where = $"n={length}, w={width}, seed={seed}, output row {outputRow} (input row {inputRow})";
                        RequireUnchanged(context, plan, inputs, width, baseline, inputRow, random, row => row > inputRow, $"rows after {inputRow} were perturbed", where);
                        if (kind == MathBlockCausality.Pointwise)
                        {
                            RequireUnchanged(context, plan, inputs, width, baseline, inputRow, random, row => row < inputRow, $"rows before {inputRow} were perturbed", where);
                            RequireUnchanged(context, plan, inputs, width, baseline, inputRow, random, row => row != inputRow, $"every row except {inputRow} was perturbed", where);
                        }
                        else if (kind == MathBlockCausality.Trailing)
                        {
                            var first = inputRow - width + 1;
                            RequireUnchanged(context, plan, inputs, width, baseline, inputRow, random, row => row < first, $"rows before the window start {first} were perturbed", where);
                            RequireUnchanged(context, plan, inputs, width, baseline, inputRow, random, row => row < first || row > inputRow, $"every row outside the window {first}..{inputRow} was perturbed", where);
                        }
                        if (context.Failures.Count != 0)
                            return;
                    }
                }
        if (context.Failures.Count == 0)
            CheckPrefixSweep(context.Operation, context.Failures);
    }

    private static void RequireUnchanged(
        Context context,
        Plan plan,
        Series[] inputs,
        int width,
        MathBlockValue baseline,
        int inputRow,
        Random random,
        Func<int, bool> perturbRow,
        string perturbation,
        string where)
    {
        var perturbed = plan.Perturb(random, inputs, perturbRow);
        var result = context.Evaluate(perturbed, width);
        if (!result.IsValid)
        {
            context.Fail($"became invalid when {perturbation} inside the input domain ({where}): {result.InvalidReason}");
            return;
        }
        var length = inputs[0].Length;
        var expectedRow = OutputRow(inputRow, length, SeriesLength(baseline));
        var actualRow = OutputRow(inputRow, length, SeriesLength(result));
        if (!RowEquals(baseline, expectedRow, result, actualRow))
            context.Fail($"changed output row {expectedRow} when {perturbation} ({where})");
    }

    private static void CheckNonCausal(Context context)
    {
        var plan = FindPlan(context, VectorDomainsWithWhole, requirePerturbableRows: false, minimumLengths: 1);
        if (plan is not null && (ReverseCheckGenerated(context, plan) || ReverseCheckLengthValidity(context, plan)))
            return;
        if (ReverseCheckSamples(context))
            return;
        foreach (var template in ParameterVariants(context.Template, context.SeriesInputs))
        {
            var variant = new Context(context.Operation, context.Failures, template);
            var variantPlan = FindPlan(variant, VectorDomainsWithWhole, requirePerturbableRows: false, minimumLengths: 1);
            if (variantPlan is not null && ReverseCheckGenerated(variant, variantPlan))
                return;
        }
        context.Fail(plan is null
            ? "has no valid input domain, and no single-row change of its sample inputs changed the output"
            : "never changed an output row (or its non-vector output) or its validity when later rows or the series length changed");
    }

    /// <summary>
    /// Yields the sample inputs with one matrix entry or graph edge weight changed, or with the graph extended to the
    /// shortest tested length, for the reverse check only: a sample parameter such as a diagonal matrix or a
    /// three-vertex path can hide a dependence that the label has to allow for.
    /// </summary>
    private static IEnumerable<MathBlockValue[]> ParameterVariants(IReadOnlyList<MathBlockValue> template, int[] seriesInputs)
    {
        for (var input = 0; input < template.Count; input++)
        {
            if (Array.IndexOf(seriesInputs, input) >= 0 || !template[input].IsValid)
                continue;
            var value = template[input];
            if (value.Type.Kind == MathBlockValueKind.Matrix)
            {
                var matrix = value.AsMatrix();
                for (var entry = 0; entry < matrix.Rows * matrix.Columns; entry++)
                {
                    var entries = matrix.ToArray();
                    entries[entry] += 0.5d * Math.Max(1d, Math.Abs(entries[entry]));
                    var variant = template.ToArray();
                    variant[input] = MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, entries), value.Type.Unit);
                    yield return variant;
                }
            }
            else if (value.Type.Kind == MathBlockValueKind.Graph)
            {
                var graph = value.AsGraph();
                var edges = graph.ToArray();
                for (var edge = 0; edge < edges.Length; edge++)
                {
                    var changed = (MathBlockGraphEdge[])edges.Clone();
                    changed[edge] = changed[edge] with { Weight = changed[edge].Weight * 3d };
                    var variant = template.ToArray();
                    variant[input] = MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, changed), value.Type.Unit);
                    yield return variant;
                }
                if (graph.VertexCount < Lengths[0])
                {
                    var larger = new List<MathBlockGraphEdge>(edges);
                    for (var vertex = graph.VertexCount - 1; vertex < Lengths[0] - 1; vertex++)
                        larger.Add(new MathBlockGraphEdge(vertex, vertex + 1, 1d + 0.5d * vertex));
                    larger.Add(new MathBlockGraphEdge(0, Lengths[0] - 1, 0.75d));
                    var variant = template.ToArray();
                    variant[input] = MathBlockValue.Graph(new MathBlockGraph(Lengths[0], larger), value.Type.Unit);
                    yield return variant;
                }
            }
        }
    }

    private static bool ReverseCheckGenerated(Context context, Plan plan)
    {
        var random = new Random(Seed(context.Operation.Identity, 0, 0, 0));
        for (var trial = 0; trial < ReverseTrials; trial++)
        {
            var length = plan.Lengths[trial % plan.Lengths.Length];
            var inputs = plan.Generate(random, length);
            var baseline = context.Evaluate(inputs, 0);
            if (!baseline.IsValid)
                continue;
            var seriesOutput = IsSeriesKind(baseline.Type.Kind);
            if (seriesOutput && !plan.PerturbableRows)
                return false;
            if (!seriesOutput)
            {
                var fresh = context.Evaluate(plan.Generate(random, length), 0);
                if (fresh.IsValid && !fresh.ApproximatelyEquals(baseline, 0d))
                    return true;
            }
            else
            {
                var outputLength = SeriesLength(baseline);
                foreach (var outputRow in PickRows(random, outputLength))
                {
                    var inputRow = InputRow(outputRow, length, outputLength);
                    var perturbed = context.Evaluate(plan.Perturb(random, inputs, row => row > inputRow), 0);
                    if (perturbed.IsValid && !RowEquals(
                            baseline, outputRow, perturbed, OutputRow(inputRow, length, SeriesLength(perturbed))))
                        return true;
                }
            }
            if (plan.RowIndependent)
            {
                var extended = plan.Extend(random, inputs, 1 + trial % 3);
                var result = context.Evaluate(extended, 0);
                if (result.IsValid && Changed(baseline, result, length, extended[0].Length))
                    return true;
            }
        }
        return false;
    }

    private static bool ReverseCheckSamples(Context context)
    {
        var samples = new IReadOnlyList<MathBlockValue>[context.Operation.RegressionCases.Count + 1];
        samples[0] = context.Operation.PerformanceCase.Inputs;
        for (var index = 0; index < context.Operation.RegressionCases.Count; index++)
            samples[index + 1] = context.Operation.RegressionCases[index].Inputs;
        foreach (var sample in samples)
        {
            var baseline = context.Operation.Evaluate(sample.ToArray());
            if (!baseline.IsValid)
                continue;
            var length = SeriesLength(sample[context.SeriesInputs[0]]);
            foreach (var input in context.SeriesInputs)
            {
                var series = Series.From(sample[input]);
                for (var row = 0; row < series.Length; row++)
                    foreach (var changed in series.Jitter(row, sample[input].Type.Unit))
                    {
                        var inputs = sample.ToArray();
                        inputs[input] = changed;
                        var result = context.Operation.Evaluate(inputs);
                        if (!result.IsValid)
                            continue;
                        if (!IsSeriesKind(baseline.Type.Kind))
                        {
                            if (!result.ApproximatelyEquals(baseline, 0d))
                                return true;
                            continue;
                        }
                        for (var outputRow = 0; outputRow < SeriesLength(baseline); outputRow++)
                        {
                            var inputRow = InputRow(outputRow, length, SeriesLength(baseline));
                            if (row > inputRow && !RowEquals(
                                    baseline, outputRow, result, OutputRow(inputRow, length, SeriesLength(result))))
                                return true;
                        }
                    }
            }
        }
        return false;
    }

    /// <summary>Evaluates an operation, treating inputs whose types the operation rejects as outside its domain.</summary>
    /// <remarks>
    /// A generated length can disagree with a parameter of fixed shape, such as a graph's vertex count, and the
    /// type resolver rejects that combination. Past type resolution, evaluation must return a value.
    /// </remarks>
    private static MathBlockValue EvaluateTyped(MathBlockOperation operation, MathBlockValue[] inputs)
    {
        try
        {
            operation.ResolveOutputType(Array.ConvertAll(inputs, input => input.Type));
        }
        catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
        {
            return MathBlockValue.Invalid(MathBlockType.Scalar(), exception.Message);
        }
        return operation.Evaluate(inputs);
    }

    private static bool TypeResolves(MathBlockOperation operation, MathBlockValue[] inputs)
    {
        try
        {
            operation.ResolveOutputType(Array.ConvertAll(inputs, input => input.Type));
            return true;
        }
        catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
        {
            return false;
        }
    }

    /// <summary>
    /// Sweeps a Pointwise, Trailing or Expanding label over the regression inputs of the operation, in two value
    /// regimes, at several lengths. Row t of the full run must equal the matching row of the run on the first t rows
    /// in value, and the run on the first t rows must be valid exactly when the full run is. Only inputs inside the
    /// operation's domain count: an out-of-domain or overflowing row invalidates a whole vector result by design, so
    /// a full run that fails while the prefix is valid is accepted when repeating the prefix rows to the full length
    /// gives a valid run.
    /// </summary>
    private static void CheckPrefixSweep(MathBlockOperation operation, List<string> failures)
    {
        var templates = new List<IReadOnlyList<MathBlockValue>>();
        var keys = new HashSet<string>(StringComparer.Ordinal);
        foreach (var inputs in operation.RegressionCases.Select(regression => regression.Inputs).Append(operation.PerformanceCase.Inputs))
            if (keys.Add(TemplateKey(inputs)))
                templates.Add(inputs);
        var regimes = new HashSet<int>();
        foreach (var template in templates.ToArray())
        {
            var context = new Context(operation, failures, template);
            var combinations = SweepCombinations(context);
            if (combinations.Count == 0)
            {
                context.Fail("has no input inside its domain for the prefix sweep");
                return;
            }
            foreach (var (domains, regime) in combinations)
            {
                regimes.Add(regime);
                if (!SweepPrefixes(context, template, domains))
                    return;
            }
        }
        var single = SingleRegimeOperations.Contains(operation.Identity);
        if (regimes.Count < 2 && !single)
            failures.Add($"{operation.Identity} ({operation.Causality}) was swept in only one value regime");
        if (regimes.Count >= 2 && single)
            failures.Add($"{operation.Identity} ({operation.Causality}) has a second value regime, so its single-regime exemption is no longer needed");
    }

    private static bool SweepPrefixes(Context context, IReadOnlyList<MathBlockValue> template, Domain[] domains)
    {
        var operation = context.Operation;
        var width = SweepWidth(context);
        var warmUpLimit = SweepWarmUpLimit(operation, template, width);
        var lengths = new SortedSet<int>(SweepLengths);
        if (context.SeriesInputs.Length != 0 && SeriesLength(template[context.SeriesInputs[0]]) <= SweepOwnLengthLimit)
            lengths.Add(SeriesLength(template[context.SeriesInputs[0]]));
        foreach (var length in lengths)
            for (var seed = 0; seed < SweepSeeds; seed++)
            {
                var random = new Random(Seed(operation.Identity, length, width, 1000 + seed));
                var full = Array.ConvertAll(domains, domain => Series.Generate(domain, random, length));
                if (!context.Accepts(full, width))
                    continue;
                var baseline = context.Evaluate(full, width);
                if (baseline.IsValid && !IsSeriesKind(baseline.Type.Kind))
                {
                    context.Fail($"returned {baseline.Type.Kind}, not a series, at n={length}");
                    return false;
                }
                for (var prefix = 1; prefix <= length; prefix++)
                {
                    var truncated = prefix == length ? full : Array.ConvertAll(full, input => input.Truncate(prefix));
                    if (!context.Accepts(truncated, width))
                        continue;
                    var result = prefix == length ? baseline : context.Evaluate(truncated, width);
                    var failure = ComparePrefix(context, full, baseline, result, length, prefix, width, warmUpLimit);
                    if (failure is not null)
                    {
                        context.Fail($"{failure} (n={length}, t={prefix}, seed={seed}, domains={string.Join('/', domains)})");
                        return false;
                    }
                }
            }
        return true;
    }

    private static string? ComparePrefix(
        Context context,
        Series[] full,
        MathBlockValue baseline,
        MathBlockValue result,
        int length,
        int prefix,
        int width,
        int warmUpLimit)
    {
        if (!baseline.IsValid && !result.IsValid)
            return null;
        if (!result.IsValid)
        {
            return prefix <= warmUpLimit
                ? null
                : $"is valid on the full series but invalid on its first {prefix} rows ({result.InvalidReason}), so validity depends on rows after row {prefix - 1} or on their number";
        }
        if (!baseline.IsValid)
        {
            var repeated = Array.ConvertAll(full, input => input.Cycle(prefix, length));
            return !context.Accepts(repeated, width) || context.Evaluate(repeated, width).IsValid
                ? null
                : $"is invalid on the full series ({baseline.InvalidReason}) but valid on its first {prefix} rows, and rows repeating those are invalid at the full length, so validity depends on rows after row {prefix - 1} or on their number";
        }
        if (!IsSeriesKind(result.Type.Kind))
            return $"returned {result.Type.Kind}, not a series, on the first {prefix} rows";
        var fullRows = SeriesLength(baseline);
        var prefixRows = SeriesLength(result);
        for (var row = 0; row < prefixRows; row++)
        {
            var inputRow = InputRow(row, prefix, prefixRows);
            if (inputRow >= prefix)
                continue;
            var fullRow = OutputRow(inputRow, length, fullRows);
            // The full run omits leading rows (a warm-up or a degenerate length), so it has no row to compare.
            if (fullRow < 0)
                continue;
            if (!RowEquals(baseline, fullRow, result, row))
                return $"changed output row {fullRow} (input row {inputRow}) when evaluated on the first {prefix} rows only";
        }
        return null;
    }

    private static int SweepWidth(Context context) =>
        context.Operation.Causality.WidthInputIndex is { } widthIndex
            ? (int)context.Template[widthIndex].AsScalar()
            : 0;

    // The number of leading prefix lengths whose run may be invalid because the window or lag is not yet covered.
    private static int SweepWarmUpLimit(MathBlockOperation operation, IReadOnlyList<MathBlockValue> template, int width)
    {
        if (operation.Causality.Kind == MathBlockCausality.Trailing)
            return width - 1;
        return WarmUpExemptions.ContainsKey(operation.Identity) ? (int)template[1].AsScalar() : 0;
    }

    private static List<(Domain[] Domains, int Regime)> SweepCombinations(Context context)
    {
        var choices = new Domain[context.SeriesInputs.Length][];
        for (var index = 0; index < choices.Length; index++)
            choices[index] = context.Template[context.SeriesInputs[index]].Type.Kind switch
            {
                MathBlockValueKind.BooleanVector => [Domain.Boolean, Domain.BooleanMostlyTrue],
                MathBlockValueKind.ComplexVector => [Domain.Complex, Domain.ComplexLarge],
                _ => [.. FirstRegimeDomains, .. SecondRegimeDomains]
            };
        var width = SweepWidth(context);
        var lengths = new SortedSet<int>(SweepProbeLengths);
        if (context.SeriesInputs.Length != 0)
            lengths.Add(SeriesLength(context.Template[context.SeriesInputs[0]]));
        var chosen = new List<(Domain[] Domains, int Regime)>();
        var perRegime = new int[3];
        foreach (var domains in SweepProducts(choices))
        {
            var regime = SweepRegime(domains);
            if (perRegime[regime] >= SweepCombinationsPerRegime)
                continue;
            var inDomain = false;
            foreach (var length in lengths)
            {
                var random = new Random(Seed(context.Operation.Identity, length, width, 99));
                var series = Array.ConvertAll(domains, domain => Series.Generate(domain, random, length));
                if (context.Accepts(series, width) && context.Evaluate(series, width).IsValid)
                {
                    inDomain = true;
                    break;
                }
            }
            if (!inDomain)
                continue;
            perRegime[regime]++;
            chosen.Add((domains, regime));
        }
        return chosen;
    }

    // Every combination for one or two series inputs; one shared domain for three or more.
    private static IEnumerable<Domain[]> SweepProducts(Domain[][] choices)
    {
        if (choices.Length <= 2)
        {
            foreach (var domains in Combinations(choices, uniformOnly: false))
                yield return domains;
            yield break;
        }
        var shared = FirstRegimeDomains.Length + SecondRegimeDomains.Length;
        for (var position = 0; position < shared; position++)
        {
            var second = position >= FirstRegimeDomains.Length;
            yield return Array.ConvertAll(choices, choice => choice.Length == 2 ? choice[second ? 1 : 0] : choice[position]);
        }
    }

    // 0 for the first value regime, 1 for the second, 2 for a mix of both.
    private static int SweepRegime(Domain[] domains)
    {
        var second = domains.Count(domain => Array.IndexOf(SecondRegimeDomains, domain) >= 0 ||
                                             domain is Domain.BooleanMostlyTrue or Domain.ComplexLarge);
        return second == 0 ? 0 : second == domains.Length ? 1 : 2;
    }

    private static string TemplateKey(IReadOnlyList<MathBlockValue> template)
    {
        var key = new StringBuilder();
        foreach (var value in template)
        {
            key.Append(value.Type.Kind.ToString()).Append(':');
            if (value.Type.Kind == MathBlockValueKind.Scalar)
                key.Append(value.AsScalar().ToString("R", CultureInfo.InvariantCulture));
            else if (value.Type.Kind == MathBlockValueKind.Boolean)
                key.Append(value.AsBoolean() ? "true" : "false");
            else if (!IsSeriesKind(value.Type.Kind))
                key.Append(value.Type.ToString());
            key.Append(';');
        }
        return key.ToString();
    }

    /// <summary>
    /// Whether an in-domain series gives a run that is valid at some lengths and invalid at others, which is a
    /// dependence on the number of rows.
    /// </summary>
    private static bool ReverseCheckLengthValidity(Context context, Plan plan)
    {
        var random = new Random(Seed(context.Operation.Identity, 0, 0, 1));
        var inputs = plan.Generate(random, SweepLengths[^1]);
        var outcomes = new HashSet<bool>();
        foreach (var length in SweepLengths)
        {
            var truncated = Array.ConvertAll(inputs, input => input.Truncate(length));
            if (context.Accepts(truncated, 0))
                outcomes.Add(context.Evaluate(truncated, 0).IsValid);
        }
        return outcomes.Count == 2;
    }

    private static bool Changed(MathBlockValue baseline, MathBlockValue result, int length, int resultLength)
    {
        if (!IsSeriesKind(baseline.Type.Kind))
            return !result.ApproximatelyEquals(baseline, 0d);
        for (var outputRow = 0; outputRow < SeriesLength(baseline); outputRow++)
        {
            var inputRow = InputRow(outputRow, length, SeriesLength(baseline));
            if (!RowEquals(baseline, outputRow, result, OutputRow(inputRow, resultLength, SeriesLength(result))))
                return true;
        }
        return false;
    }

    private static Plan? FindPlan(Context context, Domain[] vectorDomains, bool requirePerturbableRows, int minimumLengths)
    {
        var choices = new Domain[context.SeriesInputs.Length][];
        for (var index = 0; index < choices.Length; index++)
            choices[index] = context.Template[context.SeriesInputs[index]].Type.Kind switch
            {
                MathBlockValueKind.BooleanVector => [Domain.Boolean],
                MathBlockValueKind.ComplexVector => [Domain.Complex],
                _ => vectorDomains
            };
        // For the causal check, a plan whose output rows all hold the same value is kept only as a fallback: an
        // integer-domain operation lifted over real-valued rows, for example, returns its fill value on every row,
        // so no perturbation could change a row and the check would pass whatever the operation reads.
        Plan? fallback = null;
        foreach (var domains in Combinations(choices, uniformOnly: choices.Length > 2))
        {
            var plan = new Plan(domains);
            if (requirePerturbableRows && !plan.PerturbableRows)
                continue;
            var lengths = new List<int>();
            foreach (var length in context.CandidateLengths)
                if (IsValidEverywhere(context, plan, length))
                    lengths.Add(length);
            if (lengths.Count < minimumLengths)
                continue;
            var candidate = plan.WithLengths([.. lengths]);
            if (!requirePerturbableRows || RowsVary(context, candidate))
                return candidate;
            fallback ??= candidate;
        }
        return fallback;
    }

    private static bool RowsVary(Context context, Plan plan)
    {
        foreach (var length in plan.Lengths)
            foreach (var width in context.Widths(length))
                for (var seed = 0; seed < SeedCount; seed++)
                {
                    var random = new Random(Seed(context.Operation.Identity, length, width, seed));
                    var output = context.Evaluate(plan.Generate(random, length), width);
                    if (!output.IsValid || !IsSeriesKind(output.Type.Kind))
                        continue;
                    for (var row = 1; row < SeriesLength(output); row++)
                        if (!RowEquals(output, 0, output, row))
                            return true;
                }
        return false;
    }

    private static bool IsValidEverywhere(Context context, Plan plan, int length)
    {
        foreach (var width in context.Widths(length))
            for (var seed = 0; seed < SeedCount; seed++)
            {
                var random = new Random(Seed(context.Operation.Identity, length, width, seed));
                if (!context.Evaluate(plan.Generate(random, length), width).IsValid)
                    return false;
            }
        return true;
    }

    private static IEnumerable<Domain[]> Combinations(Domain[][] choices, bool uniformOnly)
    {
        if (uniformOnly)
        {
            foreach (var domain in VectorDomainsWithWhole)
                yield return Array.ConvertAll(choices, choice => choice.Length == 1 ? choice[0] : domain);
            yield break;
        }
        var indexes = new int[choices.Length];
        while (true)
        {
            var result = new Domain[choices.Length];
            for (var index = 0; index < result.Length; index++)
                result[index] = choices[index][indexes[index]];
            yield return result;
            var position = 0;
            while (position < indexes.Length && ++indexes[position] == choices[position].Length)
                indexes[position++] = 0;
            if (position == indexes.Length)
                yield break;
        }
    }

    private static int[] PickRows(Random random, int outputLength)
    {
        var rows = new SortedSet<int> { 0, outputLength - 1 };
        while (rows.Count < Math.Min(RowsPerCase, outputLength))
            rows.Add(random.Next(outputLength));
        return [.. rows];
    }

    private static int InputRow(int outputRow, int inputLength, int outputLength) =>
        outputLength <= inputLength ? outputRow + inputLength - outputLength : outputRow;

    private static int OutputRow(int inputRow, int inputLength, int outputLength) =>
        outputLength <= inputLength ? inputRow - (inputLength - outputLength) : inputRow;

    private static bool RowEquals(MathBlockValue left, int leftRow, MathBlockValue right, int rightRow)
    {
        if (left.Type.Kind != right.Type.Kind)
            return false;
        var leftExists = leftRow >= 0 && leftRow < SeriesLength(left);
        var rightExists = rightRow >= 0 && rightRow < SeriesLength(right);
        if (!leftExists || !rightExists)
            return leftExists == rightExists;
        return left.Type.Kind switch
        {
            MathBlockValueKind.Vector => BitConverter.DoubleToInt64Bits(left.AsVector()[leftRow]) ==
                                         BitConverter.DoubleToInt64Bits(right.AsVector()[rightRow]),
            MathBlockValueKind.BooleanVector => left.AsBooleanVector()[leftRow] == right.AsBooleanVector()[rightRow],
            MathBlockValueKind.ComplexVector => ComplexBitsEqual(left.AsComplexVector()[leftRow], right.AsComplexVector()[rightRow]),
            _ => throw new InvalidOperationException($"'{left.Type.Kind}' has no rows.")
        };
    }

    private static bool ComplexBitsEqual(Complex left, Complex right) =>
        BitConverter.DoubleToInt64Bits(left.Real) == BitConverter.DoubleToInt64Bits(right.Real) &&
        BitConverter.DoubleToInt64Bits(left.Imaginary) == BitConverter.DoubleToInt64Bits(right.Imaginary);

    private static bool IsSeriesKind(MathBlockValueKind kind) =>
        kind is MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector or MathBlockValueKind.ComplexVector;

    private static int SeriesLength(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        MathBlockValueKind.ComplexVector => value.AsComplexVector().Count,
        _ => 0
    };

    private static string Describe(MathBlockValue value) =>
        value.IsValid ? value.Type.Kind.ToString() : $"an invalid {value.Type.Kind} ({value.InvalidReason})";

    private static int Seed(string identity, int length, int width, int seed)
    {
        var hash = 17;
        foreach (var character in identity)
            hash = unchecked(hash * 31 + character);
        return unchecked(((hash * 31 + length) * 31 + width) * 31 + seed);
    }

    private sealed class Context
    {
        public Context(MathBlockOperation operation, List<string> failures)
            : this(operation, failures, operation.PerformanceCase.Inputs)
        {
        }

        public Context(MathBlockOperation operation, List<string> failures, IReadOnlyList<MathBlockValue> template)
        {
            Operation = operation;
            Failures = failures;
            Template = template;
            var series = new List<int>();
            for (var index = 0; index < Template.Count; index++)
                if (IsSeriesKind(Template[index].Type.Kind))
                    series.Add(index);
            SeriesInputs = [.. series];
            var candidates = new SortedSet<int>(Lengths);
            if (SeriesInputs.Length != 0)
                candidates.Add(SeriesLength(Template[SeriesInputs[0]]));
            CandidateLengths = [.. candidates];
        }

        public MathBlockOperation Operation { get; }
        public List<string> Failures { get; }
        public IReadOnlyList<MathBlockValue> Template { get; }
        public int[] SeriesInputs { get; }
        public int[] CandidateLengths { get; }

        public void Fail(string message) => Failures.Add($"{Operation.Identity} ({Operation.Causality}) {message}");

        public int[] Widths(int length)
        {
            if (Operation.Causality.WidthInputIndex is null)
                return [0];
            var widths = new SortedSet<int>();
            foreach (var width in new[] { 1, 2, 3, 5, length })
                if (width <= length)
                    widths.Add(width);
            return [.. widths];
        }

        public MathBlockValue Evaluate(Series[] series, int width) => EvaluateTyped(Operation, BuildInputs(series, width));

        /// <summary>Gets whether the type resolver accepts the series, as opposed to the operation judging them invalid.</summary>
        public bool Accepts(Series[] series, int width) => TypeResolves(Operation, BuildInputs(series, width));

        private MathBlockValue[] BuildInputs(Series[] series, int width)
        {
            var inputs = Template.ToArray();
            for (var index = 0; index < SeriesInputs.Length; index++)
                inputs[SeriesInputs[index]] = series[index].ToValue(Template[SeriesInputs[index]].Type.Unit);
            if (Operation.Causality.WidthInputIndex is { } widthIndex)
                inputs[widthIndex] = MathBlockValue.Scalar(width, Template[widthIndex].Type.Unit);
            return inputs;
        }
    }

    private sealed class Plan
    {
        private readonly Domain[] domains;

        public Plan(Domain[] domains)
        {
            this.domains = domains;
            RowIndependent = Array.TrueForAll(domains, domain => domain is not (Domain.Sorted or Domain.Probability));
            PerturbableRows = Array.TrueForAll(domains, domain => domain is not Domain.Sorted);
            Lengths = [];
        }

        private Plan(Plan source, int[] lengths)
        {
            domains = source.domains;
            RowIndependent = source.RowIndependent;
            PerturbableRows = source.PerturbableRows;
            Lengths = lengths;
        }

        /// <summary>Gets whether each row is drawn independently, so a prefix or an extension stays in the domain.</summary>
        public bool RowIndependent { get; }

        /// <summary>Gets whether any set of rows can be redrawn inside the domain.</summary>
        public bool PerturbableRows { get; }

        public int[] Lengths { get; }

        public Plan WithLengths(int[] lengths) => new(this, lengths);

        public Series[] Generate(Random random, int length) =>
            Array.ConvertAll(domains, domain => Series.Generate(domain, random, length));

        public Series[] Perturb(Random random, Series[] inputs, Func<int, bool> perturbRow)
        {
            var result = new Series[inputs.Length];
            for (var index = 0; index < inputs.Length; index++)
                result[index] = inputs[index].Perturb(domains[index], random, perturbRow);
            return result;
        }

        public Series[] Extend(Random random, Series[] inputs, int rows)
        {
            var result = new Series[inputs.Length];
            for (var index = 0; index < inputs.Length; index++)
                result[index] = inputs[index].Extend(domains[index], random, rows);
            return result;
        }
    }

    /// <summary>One generated vector-kind input.</summary>
    private sealed class Series
    {
        private readonly double[]? real;
        private readonly bool[]? boolean;
        private readonly Complex[]? complex;

        private Series(double[]? real, bool[]? boolean, Complex[]? complex)
        {
            this.real = real;
            this.boolean = boolean;
            this.complex = complex;
            Length = real?.Length ?? boolean?.Length ?? complex!.Length;
        }

        public int Length { get; }

        public static Series From(MathBlockValue value) => value.Type.Kind switch
        {
            MathBlockValueKind.Vector => new Series(value.AsVector().ToArray(), null, null),
            MathBlockValueKind.BooleanVector => new Series(null, value.AsBooleanVector().ToArray(), null),
            MathBlockValueKind.ComplexVector => new Series(null, null, value.AsComplexVector().ToArray()),
            _ => throw new InvalidOperationException($"'{value.Type.Kind}' is not a vector kind.")
        };

        public static Series Generate(Domain domain, Random random, int length)
        {
            if (domain is Domain.Boolean or Domain.BooleanMostlyTrue)
            {
                var flags = new bool[length];
                for (var index = 0; index < length; index++)
                    flags[index] = domain == Domain.Boolean ? random.Next(2) == 1 : random.NextDouble() < 0.85d;
                return new Series(null, flags, null);
            }
            if (domain is Domain.Complex or Domain.ComplexLarge)
            {
                var scale = domain == Domain.Complex ? 2d : 1000d;
                var numbers = new Complex[length];
                for (var index = 0; index < length; index++)
                    numbers[index] = new Complex(Uniform(random, -scale, scale), Uniform(random, -scale, scale));
                return new Series(null, null, numbers);
            }
            var values = new double[length];
            if (domain == Domain.Sorted)
            {
                var current = -2d;
                for (var index = 0; index < length; index++)
                    values[index] = current += Uniform(random, 0.1d, 1d);
            }
            else if (domain == Domain.Probability)
            {
                var total = 0d;
                for (var index = 0; index < length; index++)
                    total += values[index] = Uniform(random, 0.25d, 4d);
                for (var index = 0; index < length; index++)
                    values[index] /= total;
            }
            else
            {
                for (var index = 0; index < length; index++)
                    values[index] = NextReal(domain, random, length);
            }
            return new Series(values, null, null);
        }

        public Series Perturb(Domain domain, Random random, Func<int, bool> perturbRow)
        {
            if (domain == Domain.Probability)
                return PerturbMass(random, perturbRow);
            var result = Copy(Length);
            for (var row = 0; row < Length; row++)
            {
                if (!perturbRow(row))
                    continue;
                if (result.real is not null)
                    result.real[row] = NextDifferentReal(domain, random, Length, real![row]);
                else if (result.boolean is not null)
                    result.boolean[row] = random.Next(2) == 1;
                else
                    result.complex![row] = new Complex(Uniform(random, -2d, 2d), Uniform(random, -2d, 2d));
            }
            return result;
        }

        /// <summary>Redraws the chosen rows of a distribution and rescales them to their previous total.</summary>
        private Series PerturbMass(Random random, Func<int, bool> perturbRow)
        {
            var result = Copy(Length);
            var values = result.real!;
            var previous = 0d;
            var drawn = 0d;
            for (var row = 0; row < Length; row++)
            {
                if (!perturbRow(row))
                    continue;
                previous += values[row];
                drawn += values[row] = Uniform(random, 0.25d, 4d);
            }
            for (var row = 0; row < Length; row++)
                if (perturbRow(row))
                    values[row] *= previous / drawn;
            return result;
        }

        public Series Extend(Domain domain, Random random, int rows)
        {
            var extra = Generate(domain, random, rows);
            if (real is not null)
                return new Series([.. real, .. extra.real!], null, null);
            if (boolean is not null)
                return new Series(null, [.. boolean, .. extra.boolean!], null);
            return new Series(null, null, [.. complex!, .. extra.complex!]);
        }

        public Series Truncate(int length) => Copy(length);

        /// <summary>Returns a series of the given length that repeats the first rows in order.</summary>
        public Series Cycle(int rows, int length) => new(
            real is null ? null : Enumerable.Range(0, length).Select(row => real[row % rows]).ToArray(),
            boolean is null ? null : Enumerable.Range(0, length).Select(row => boolean[row % rows]).ToArray(),
            complex is null ? null : Enumerable.Range(0, length).Select(row => complex[row % rows]).ToArray());

        public IEnumerable<MathBlockValue> Jitter(int row, MathBlockUnit unit)
        {
            if (real is not null)
            {
                foreach (var change in new[] { 0.125d, -0.125d, 1d, -0.9d, -3d })
                {
                    var values = (double[])real.Clone();
                    values[row] += change * Math.Max(1d, Math.Abs(values[row]));
                    yield return MathBlockValue.Vector(values, unit);
                }
            }
            else if (boolean is not null)
            {
                var values = (bool[])boolean.Clone();
                values[row] = !values[row];
                yield return MathBlockValue.BooleanVector(values);
            }
            else
            {
                var values = (Complex[])complex!.Clone();
                values[row] = new Complex(values[row].Real + 0.125d, values[row].Imaginary - 0.25d);
                yield return MathBlockValue.ComplexVector(values, unit);
            }
        }

        public MathBlockValue ToValue(MathBlockUnit unit)
        {
            if (real is not null)
                return MathBlockValue.Vector(real, unit);
            if (boolean is not null)
                return MathBlockValue.BooleanVector(boolean);
            return MathBlockValue.ComplexVector(complex!, unit);
        }

        private Series Copy(int length) => new(
            real?[..length],
            boolean?[..length],
            complex?[..length]);

        private static double NextReal(Domain domain, Random random, int length) => domain switch
        {
            Domain.Real => Uniform(random, -2d, 2d),
            Domain.Positive => Uniform(random, 0.25d, 4d),
            Domain.Unit => Uniform(random, 0.05d, 0.95d),
            Domain.SmallMass => Uniform(random, 0.2d, 0.8d) / length,
            Domain.Count => random.Next(4),
            Domain.Index => random.Next(length),
            // Integers on both sides of zero, so an integer-only operation is valid on some rows and invalid on
            // others, and so is its validity sibling.
            Domain.Integer => random.Next(-2, 6),
            Domain.LargeReal => Uniform(random, -1000d, 1000d),
            Domain.LargePositive => Uniform(random, 100d, 10000d),
            _ => throw new InvalidOperationException($"Domain '{domain}' has no independent rows.")
        };

        private static double NextDifferentReal(Domain domain, Random random, int length, double current)
        {
            for (var attempt = 0; attempt < 16; attempt++)
            {
                var value = NextReal(domain, random, length);
                if (BitConverter.DoubleToInt64Bits(value) != BitConverter.DoubleToInt64Bits(current))
                    return value;
            }
            return NextReal(domain, random, length);
        }

        private static double Uniform(Random random, double minimum, double maximum) =>
            minimum + (maximum - minimum) * random.NextDouble();
    }

    /// <summary>Formats a failure list for an assertion message.</summary>
    public static string Format(List<string> failures) =>
        string.Create(CultureInfo.InvariantCulture, $"{failures.Count} causality label failure(s):{Environment.NewLine}{string.Join(Environment.NewLine, failures)}");
}
