using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The CoreCLR safety proof of window.vector.standardize@1, vector.scale@1 and vector.subtract@1 as PatternResearcher's device route calls them (the whole-vector contracts, the
/// elementwise twins of the scalar operations with their validity siblings, and the window form with its validity sibling), in the normal suite: every EvaluateCoreCLR overload the route can
/// reach agrees bit for bit over the input-class matrix and the real market columns; the labels, the output length, the refusal of a length mismatch, the empty input; the zero-variance and
/// variance-overflow windows and the warm-up rows; and causality at every window size of the proof.
/// </summary>
public sealed class VectorBlockSafetyTests
{
    private const int LongRows = 600;
    private const int MaximumFailures = 20;

    /// <summary>Verifies the causality labels of the three identities and of the window validity sibling are the catalog's.</summary>
    [Fact]
    public void TheCausalityLabelsAreTheCatalogs()
    {
        Assert.Equal(MathBlockCausality.Pointwise, MathBlockCatalog.Standard.Get("vector.scale").Causality.Kind);
        Assert.Equal(MathBlockCausality.Pointwise, MathBlockCatalog.Standard.Get("vector.subtract").Causality.Kind);
        Assert.Equal(MathBlockCausality.WholeSeries, MathBlockCatalog.Standard.Get("vector.standardize").Causality.Kind);
        var form = MathBlockCatalog.Standard.Get("window.vector.standardize").Causality;
        Assert.Equal(MathBlockCausality.Trailing, form.Kind);
        Assert.Equal(1, form.WidthInputIndex);
        Assert.Equal(MathBlockCausality.Trailing, MathBlockCatalog.Standard.Get("window-valid.vector.standardize").Causality.Kind);
    }

    /// <summary>Verifies the lifted route's contracts are the elementwise twins that the catalog names for the scalar operations.</summary>
    [Fact]
    public void TheLiftedRouteDispatchesTheCatalogsElementwiseTwins()
    {
        Assert.True(MathBlockCatalog.TryGetElementwiseTwin("scalar.multiply@1", out var multiply));
        Assert.Equal("elementwise.scalar.multiply@1", multiply);
        Assert.True(MathBlockCatalog.TryGetElementwiseTwin("scalar.subtract@1", out var subtract));
        Assert.Equal("elementwise.scalar.subtract@1", subtract);
        var calls = VectorBlockCalls.All(includeLifted: true);
        for (var index = 0; index < calls.Count; index++)
        {
            for (var step = 0; step < calls[index].Contracts.Length; step++)
                Assert.Equal(calls[index].Contracts[step], MathBlockCudaDeviceModule.GetOperation(calls[index].Contracts[step]).Identity);
        }
    }

    /// <summary>
    /// Verifies that every overload of the route gives one result in value and validity for every call, every input class and every series length, among them the shortest series and, for the
    /// window form, the series shorter than the window; and that an elementwise form's validity span is its validity sibling, with the fill in every row that was not computed.
    /// </summary>
    [Fact]
    public void EveryOverloadAgreesBitForBitOverTheClassMatrix()
    {
        var failures = new List<string>();
        var calls = VectorBlockCalls.All(includeLifted: true);
        if (ProofRealData.Get() is null)
            Console.WriteLine($"Real market class skipped: {ProofRealData.SkipReason}");
        for (var callIndex = 0; callIndex < calls.Count; callIndex++)
        {
            var call = calls[callIndex];
            int[] lengths = [.. VectorBlockCalls.ShortRows(call), LongRows];
            for (var lengthIndex = 0; lengthIndex < lengths.Length; lengthIndex++)
                CompareOverloads(call, lengths[lengthIndex], failures);
        }

        ProofBar.Fail("Overload agreement", failures);
    }

    /// <summary>
    /// Verifies every call returns exactly as many rows as the series has, at several lengths, and that a window wider than the series gives a
    /// wholly invalid result.
    /// </summary>
    [Fact]
    public void TheOutputHasTheLengthOfTheInput()
    {
        var failures = new List<string>();
        int[] lengths = [1, 2, 3, 17, 300];
        var calls = VectorBlockCalls.All(includeLifted: true);
        for (var lengthIndex = 0; lengthIndex < lengths.Length; lengthIndex++)
        {
            var set = ProofSets.ForRows(lengths[lengthIndex], includeReal: false)[0];
            for (var callIndex = 0; callIndex < calls.Count; callIndex++)
            {
                for (var step = 0; step < calls[callIndex].Contracts.Length; step++)
                {
                    var inputs = VectorBlockCalls.Inputs(calls[callIndex], step, VectorBlockCalls.Clean(set.First), VectorBlockCalls.Clean(set.Second));
                    var result = MathBlockCudaDeviceModule.GetOperation(calls[callIndex].Contracts[step]).EvaluateCoreCLR(inputs);
                    var rows = !result.IsValid ? -1 : result.Type.Kind == MathBlockValueKind.BooleanVector ? result.AsBooleanVector().ToArray().Length : result.AsVector().ToArray().Length;
                    // The window form refuses a width larger than the series with a wholly invalid result (MathBlockWindowForm, unchanged since 0.6.1).
                    var expected = calls[callIndex].IsWindow && calls[callIndex].Width > lengths[lengthIndex] ? -1 : lengths[lengthIndex];
                    if (rows != expected)
                        failures.Add(string.Create(CultureInfo.InvariantCulture, $"{calls[callIndex].Contracts[step]} {calls[callIndex].Parameter}: {rows} rows for {lengths[lengthIndex]} (-1 is invalid)"));
                }
            }
        }

        ProofBar.Fail("Output length", failures);
    }

    /// <summary>Verifies that a second vector of another length is refused, never a valid result, by every overload of every subtract contract.</summary>
    [Fact]
    public void ALengthMismatchIsRefused()
    {
        var failures = new List<string>();
        var first = MathBlockValue.Vector([1f, 2f, 3f, 4f, 5f], MathBlockUnit.Dimensionless);
        var second = MathBlockValue.Vector([1f, 2f, 3f, 4f], MathBlockUnit.Dimensionless);
        string[] identities = [VectorBlockCalls.Subtract, "elementwise.scalar.subtract@1", "elementwise-valid.scalar.subtract@1"];
        for (var index = 0; index < identities.Length; index++)
        {
            MathBlockValue[] inputs = index == 1 ? [first, second, MathBlockValue.Scalar(VectorBlockCalls.Fill)] : [first, second];
            var contract = MathBlockCudaDeviceModule.GetOperation(identities[index]);
            IReadOnlyList<MathBlockValue> list = inputs;
            string[] outcomes = [VectorBlockReference.Outcome(() => contract.EvaluateCoreCLR(inputs)), VectorBlockReference.Outcome(() => contract.EvaluateCoreCLR(list)), VectorBlockReference.Outcome(() => contract.EvaluateCoreCLR(list, new MathBlockDomainOptions()))];
            for (var outcome = 0; outcome < outcomes.Length; outcome++)
            {
                if (outcomes[outcome].StartsWith("valid", StringComparison.Ordinal))
                    failures.Add(identities[index] + " " + VectorBlockReference.OverloadNames[outcome] + ": a length mismatch gave " + outcomes[outcome]);
            }
        }

        ProofBar.Fail("Length mismatch", failures);
    }

    /// <summary>Verifies an empty input gives one outcome on every overload, for every contract of the proof.</summary>
    [Fact]
    public void AnEmptyInputGivesOneOutcomeOnEveryOverload()
    {
        var failures = new List<string>();
        var calls = VectorBlockCalls.All(includeLifted: true);
        for (var callIndex = 0; callIndex < calls.Count; callIndex++)
        {
            for (var step = 0; step < calls[callIndex].Contracts.Length; step++)
            {
                var call = calls[callIndex];
                var identity = call.Contracts[step];
                var stepIndex = step;
                var outcomes = new string[VectorBlockReference.OverloadCount];
                for (var overload = 0; overload < outcomes.Length; overload++)
                {
                    var which = overload;
                    outcomes[overload] = VectorBlockReference.Outcome(() => VectorBlockReference.Overloads(identity, VectorBlockCalls.Inputs(call, stepIndex, [], []), 0)[which]);
                }

                if (outcomes.Distinct(StringComparer.Ordinal).Take(2).Count() != 1)
                    failures.Add(identity + " " + call.Parameter + ": " + string.Join('\n', outcomes));
            }
        }

        ProofBar.Fail("Empty input", failures);
    }

    /// <summary>
    /// Verifies a vector that holds NaN or an infinity is never a valid input of any contract of the proof (PatternResearcher reads such a row as zero and marks it invalid before the call).
    /// </summary>
    [Fact]
    public void ANonFiniteInputIsNeverValid()
    {
        var failures = new List<string>();
        var raw = ProofSets.ForRows(LongRows, includeReal: false)[(int)ProofClass.Invalid].First;
        Assert.Contains(raw, value => !float.IsFinite(value));
        var calls = VectorBlockCalls.All(includeLifted: true);
        for (var callIndex = 0; callIndex < calls.Count; callIndex++)
        {
            for (var step = 0; step < calls[callIndex].Contracts.Length; step++)
            {
                var call = calls[callIndex];
                var contract = MathBlockCudaDeviceModule.GetOperation(call.Contracts[step]);
                var outcome = VectorBlockReference.Outcome(() => contract.EvaluateCoreCLR(VectorBlockCalls.Inputs(call, step, raw, raw)));
                if (outcome.StartsWith("valid", StringComparison.Ordinal))
                    failures.Add(call.Contracts[step] + " " + call.Parameter + ": a vector with a non-finite row gave " + outcome);
            }
        }

        ProofBar.Fail("Non-finite input", failures);
    }

    /// <summary>Verifies the warm-up rows of the window form are invalid and hold the fill, and the first row of a full window is valid, at every window size.</summary>
    [Fact]
    public void TheWarmUpRowsAreInvalid()
    {
        var failures = new List<string>();
        for (var index = 0; index < VectorBlockCalls.Windows.Length; index++)
        {
            var width = VectorBlockCalls.Windows[index];
            var series = ProofData.Series(ProofClass.Typical, width + 20, 900 + index, 0, false);
            var (values, valid) = Window(series, width);
            for (var row = 0; row < series.Length; row++)
            {
                var warm = row < width - 1;
                if (valid[row] == warm || (warm && BitConverter.SingleToInt32Bits(values[row]) != BitConverter.SingleToInt32Bits(VectorBlockCalls.Fill)))
                    failures.Add(string.Create(CultureInfo.InvariantCulture, $"window {width} row {row}: valid {valid[row]}, value {values[row]:R}"));
            }
        }

        ProofBar.Fail("Warm-up rows", failures);
    }

    /// <summary>Verifies a window of one repeated value (zero variance) and a window whose variance overflows are invalid and hold the fill, at every window size.</summary>
    [Fact]
    public void ZeroVarianceAndVarianceOverflowWindowsAreInvalid()
    {
        var failures = new List<string>();
        for (var index = 0; index < VectorBlockCalls.Windows.Length; index++)
        {
            var width = VectorBlockCalls.Windows[index];
            var constant = new float[width + 5];
            Array.Fill(constant, 5f);
            var alternating = new float[width + 5];
            for (var row = 0; row < alternating.Length; row++)
                alternating[row] = row % 2 == 0 ? 1e25f : -1e25f;
            foreach (var (name, series) in new[] { ("constant", constant), ("alternating 1e200", alternating) })
            {
                var (values, valid) = Window(series, width);
                for (var row = 0; row < series.Length; row++)
                {
                    if (valid[row] || BitConverter.SingleToInt32Bits(values[row]) != BitConverter.SingleToInt32Bits(VectorBlockCalls.Fill))
                        failures.Add(string.Create(CultureInfo.InvariantCulture, $"{name} window {width} row {row}: valid {valid[row]}, value {values[row]:R}"));
                }
            }
        }

        ProofBar.Fail("Zero variance and variance overflow", failures);
    }

    /// <summary>
    /// Verifies that perturbing any one later row leaves every earlier row of the window form unchanged in value and validity, at every window size: every prefix of the perturbed series gives
    /// the same earlier rows.
    /// </summary>
    [Fact]
    public void StandardizeIsCausalAtEveryWindowSize()
    {
        var failures = new List<string>();
        for (var index = 0; index < VectorBlockCalls.Windows.Length; index++)
        {
            var width = VectorBlockCalls.Windows[index];
            var series = ProofData.Series(ProofClass.Typical, width + 24, 950 + index, 0, false);
            var (baseValues, baseValid) = Window(series, width);
            for (var later = 1; later < series.Length && failures.Count < MaximumFailures; later++)
            {
                var changed = (float[])series.Clone();
                changed[later] = (changed[later] * 3f) + 7f;
                var (values, valid) = Window(changed, width);
                for (var row = 0; row < later; row++)
                {
                    if (valid[row] != baseValid[row] || BitConverter.SingleToInt32Bits(values[row]) != BitConverter.SingleToInt32Bits(baseValues[row]))
                        failures.Add(string.Create(CultureInfo.InvariantCulture, $"window {width}: changing row {later} changed row {row}"));
                }
            }
        }

        ProofBar.Fail("Causality", failures);
    }

    // The window form and its validity sibling over the series, with the fill, as the route calls them.
    private static (float[] Values, bool[] Valid) Window(float[] series, int width)
    {
        var vector = MathBlockValue.Vector(series, MathBlockUnit.Dimensionless);
        var form = MathBlockCudaDeviceModule.GetOperation(VectorBlockCalls.Standardize).EvaluateCoreCLR(vector, MathBlockValue.Scalar(width), MathBlockValue.Scalar(VectorBlockCalls.Fill));
        var validity = MathBlockCudaDeviceModule.GetOperation("window-valid.vector.standardize@1").EvaluateCoreCLR(vector, MathBlockValue.Scalar(width));
        Assert.True(form.IsValid && validity.IsValid, "The window form was invalid as a whole.");
        return (form.AsVector().ToArray(), validity.AsBooleanVector().ToArray());
    }

    private static void CompareOverloads(VectorBlockCall call, int rows, List<string> failures)
    {
        var sets = ProofSets.ForRows(rows, includeReal: true);
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var first = VectorBlockCalls.Clean(sets[setIndex].First);
            var second = VectorBlockCalls.Clean(sets[setIndex].Second);
            MathBlockValue? form = null;
            for (var step = 0; step < call.Contracts.Length; step++)
            {
                var inputs = VectorBlockCalls.Inputs(call, step, first, second);
                var results = VectorBlockReference.Overloads(call.Contracts[step], inputs, rows);
                for (var overload = 1; overload < results.Length && failures.Count < MaximumFailures; overload++)
                {
                    var difference = VectorBlockReference.Difference(results[0], results[overload]);
                    if (difference is not null)
                        failures.Add(string.Create(CultureInfo.InvariantCulture, $"{call.Contracts[step]} {call.Parameter} class {sets[setIndex].Name} rows {rows}: {VectorBlockReference.OverloadNames[overload]} differs from {VectorBlockReference.OverloadNames[0]}: {difference}"));
                }

                if (step == 0)
                    form = results[0];
                else if (call.IsLifted && form is { } formValue)
                    CheckFill(call, sets[setIndex].Name, rows, formValue, results[0], failures);
            }
        }
    }

    // A row of an elementwise form that the validity sibling marks not computed holds the fill; a computed row is finite.
    private static void CheckFill(VectorBlockCall call, string className, int rows, MathBlockValue form, MathBlockValue validity, List<string> failures)
    {
        if (!form.IsValid || !validity.IsValid)
        {
            failures.Add(string.Create(CultureInfo.InvariantCulture, $"{call.Contracts[0]} {call.Parameter} class {className} rows {rows}: the elementwise pair was invalid as a whole"));
            return;
        }

        var values = form.AsVector().ToArray();
        var flags = validity.AsBooleanVector().ToArray();
        for (var row = 0; row < values.Length && failures.Count < MaximumFailures; row++)
        {
            var ok = flags[row] ? float.IsFinite(values[row]) : BitConverter.SingleToInt32Bits(values[row]) == BitConverter.SingleToInt32Bits(VectorBlockCalls.Fill);
            if (!ok)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{call.Contracts[0]} {call.Parameter} class {className} rows {rows} row {row}: valid {flags[row]}, value {values[row]:R}"));
        }
    }
}
