using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The safety proof of the six new sequence operations and their -valid siblings on CoreCLR, in the normal suite: every row's value bits and validity against an independent
/// evaluation of the design over the input-class matrix (the seven base classes, Mixed, the all-false predicate and the real market columns when present), four counts classes
/// and PatternResearcher's parameter range; the output length; the causality label; and the whole-call-invalid inputs.
/// </summary>
public sealed class SequenceSafetyTests
{
    private const int Rows = 600;
    private const int GapPeriod = 7;
    private const int SeriesPeriod = 101;
    private const int MaximumFailures = 20;

    /// <summary>Verifies lead and lag, with their siblings, against the oracle for every class, counts class and k.</summary>
    [Fact]
    public void LeadAndLagMatchTheDesignOverTheClassMatrix()
    {
        Sweep("lead");
        Sweep(SequenceOps.Lag);
    }

    /// <summary>Verifies first-true-offset, with its sibling, against the oracle for every class, counts class and offset range.</summary>
    [Fact]
    public void FirstTrueOffsetMatchesTheDesignOverTheClassMatrix() => Sweep(SequenceOps.FirstTrue);

    /// <summary>Verifies sum-over-offsets and maximum-over-offsets, with their siblings, against the oracle for every class, counts class and offset range.</summary>
    [Fact]
    public void SumAndMaximumOverOffsetsMatchTheDesignOverTheClassMatrix()
    {
        Sweep("sum-over-offsets");
        Sweep("maximum-over-offsets");
    }

    /// <summary>Verifies the prefix difference over offsets, with its sibling, against the oracle for every class, counts class and offset range.</summary>
    [Fact]
    public void PrefixDifferenceMatchesTheDesignOverTheClassMatrix() => Sweep("prefix-difference-over-offsets");

    /// <summary>Verifies every operation and sibling returns exactly as many rows as the series has, also when the parameter reaches past the series.</summary>
    [Fact]
    public void TheOutputHasTheLengthOfTheInput()
    {
        var failures = new List<string>();
        int[] lengths = [1, 2, 3, 17, 1000];
        for (var lengthIndex = 0; lengthIndex < lengths.Length; lengthIndex++)
        {
            var length = lengths[lengthIndex];
            var set = ProofSets.ForSequences(length, includeReal: false, includeAllFalse: false)[0];
            var counts = ProofCounts.Build(0, length, GapPeriod, SeriesPeriod);
            for (var nameIndex = 0; nameIndex < SequenceOps.Names.Length; nameIndex++)
            {
                var name = SequenceOps.Names[nameIndex];
                var parameters = SequenceOps.IsShift(name) ? SequenceOps.ShiftSafety : SequenceOps.SpanSafety;
                for (var parameterIndex = 0; parameterIndex < parameters.Length; parameterIndex++)
                    CheckLength(name, set, counts, parameters[parameterIndex], failures);
            }
        }

        ProofBar.Fail("Output length", failures);
    }

    /// <summary>Verifies lag is labelled Expanding and every other operation and every sibling is labelled Forward.</summary>
    [Fact]
    public void TheCausalityLabelIsForwardExceptForLagWhichIsExpanding()
    {
        for (var index = 0; index < SequenceOps.Names.Length; index++)
        {
            var name = SequenceOps.Names[index];
            var expected = string.Equals(name, SequenceOps.Lag, StringComparison.Ordinal) ? MathBlockCausality.Expanding : MathBlockCausality.Forward;
            Assert.Equal(expected, SequenceOps.Operation(name, false).Causality.Kind);
            Assert.Equal(expected, SequenceOps.Operation(name, true).Causality.Kind);
            Assert.Null(SequenceOps.Operation(name, false).Causality.WidthInputIndex);
        }
    }

    /// <summary>
    /// Verifies a k below 1, a non-integer k, start above end, a non-integer start or end, a non-integer or negative count and series of different lengths all make
    /// the value operation and its sibling invalid as a whole, or are rejected by the type rule.
    /// </summary>
    [Fact]
    public void BadParametersAndBadCountsInvalidateTheWholeCall()
    {
        var set = ProofSets.ForSequences(40, includeReal: false, includeAllFalse: false)[0];
        var good = ProofCounts.Build(0, 40, GapPeriod, SeriesPeriod);
        var failures = new List<string>();
        for (var index = 0; index < SequenceOps.Names.Length; index++)
        {
            var name = SequenceOps.Names[index];
            var bad = BadParameters(SequenceOps.IsShift(name));
            for (var parameterIndex = 0; parameterIndex < bad.Length; parameterIndex++)
                CheckInvalid(name, set, good, bad[parameterIndex], failures);
            var one = SequenceOps.IsShift(name) ? new ProofParameter("k=1", 1d, 1d, 1d) : new ProofParameter("[0,1]", 0d, 1d, 2d);
            double[] fractional = [.. good];
            fractional[5] = 1.5d;
            CheckInvalid(name, set, fractional, one, failures);
            double[] negative = [.. good];
            negative[5] = -1d;
            CheckInvalid(name, set, negative, one, failures);
            CheckMismatch(name, set, good, one, failures);
        }

        ProofBar.Fail("Whole-call invalid inputs", failures);
    }

    // Parameter settings that make the whole call invalid: k below 1 or not an integer, or start above end or not an integer.
    private static ProofParameter[] BadParameters(bool shift)
    {
        if (shift)
            return [new("k=0", 0d, 0d, 1d), new("k=-1", -1d, -1d, 1d), new("k=0.5", 0.5d, 0.5d, 1d), new("k=1.5", 1.5d, 1.5d, 1d)];
        return [new("start>end", 2d, 1d, 1d), new("start=0.5", 0.5d, 1d, 1d), new("end=1.5", 0d, 1.5d, 1d), new("start=-0.25", -0.25d, 0d, 1d)];
    }

    private static void Sweep(string name)
    {
        var sets = ProofSets.ForSequences(Rows, includeReal: true, includeAllFalse: true);
        if (ProofRealData.Get() is null)
            Console.WriteLine(string.Create(CultureInfo.InvariantCulture, $"Real market class skipped: {ProofRealData.SkipReason}"));
        var parameters = SequenceOps.Parameters(name, SequenceOps.ShiftSafety, SequenceOps.SpanSafety);
        var failures = new List<string>();
        var cases = 0;
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var set = sets[setIndex];
            var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
            var availability = MathBlockValue.BooleanVector(set.Available);
            for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
            {
                var counts = ProofCounts.Build(kind, Rows, GapPeriod, SeriesPeriod);
                var countsValue = MathBlockValue.Vector(counts);
                for (var parameterIndex = 0; parameterIndex < parameters.Length; parameterIndex++)
                {
                    var parameter = parameters[parameterIndex];
                    var label = string.Create(CultureInfo.InvariantCulture, $"{name} class {set.Name} counts {ProofCounts.Name(kind, GapPeriod, SeriesPeriod)} parameter {parameter.Label}");
                    var expected = SequenceOracle.Run(name, SequenceOps.Series(name, set), set.Available, counts, (long)parameter.First, (long)parameter.Second);
                    var values = SequenceOps.Operation(name, false).Evaluate(SequenceOps.Inputs(name, false, series, availability, countsValue, parameter.First, parameter.Second));
                    var flags = SequenceOps.Operation(name, true).Evaluate(SequenceOps.Inputs(name, true, series, availability, countsValue, parameter.First, parameter.Second));
                    CompareRows(label, values, flags, expected, failures);
                    cases++;
                }
            }
        }

        Assert.True(cases > 0, "No case ran.");
        ProofBar.Fail(name, failures);
    }

    private static void CompareRows(string label, MathBlockValue values, MathBlockValue flags, (double[] Values, bool[] Valid) expected, List<string> failures)
    {
        if (!values.IsValid || !flags.IsValid)
        {
            failures.Add(label + ": the call was invalid as a whole.");
            return;
        }

        var actualValues = values.AsVector().ToArray();
        var actualFlags = flags.AsBooleanVector().ToArray();
        if (actualValues.Length != expected.Values.Length || actualFlags.Length != expected.Valid.Length)
        {
            failures.Add(label + ": the output length differs from the input length.");
            return;
        }

        for (var row = 0; row < actualValues.Length && failures.Count < MaximumFailures; row++)
        {
            if (actualFlags[row] != expected.Valid[row] || BitConverter.DoubleToInt64Bits(actualValues[row]) != BitConverter.DoubleToInt64Bits(expected.Values[row]))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: expected {expected.Values[row]:R}/{expected.Valid[row]}, actual {actualValues[row]:R}/{actualFlags[row]}"));
        }
    }

    private static void CheckLength(string name, ProofSet set, double[] counts, ProofParameter parameter, List<string> failures)
    {
        var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
        var availability = MathBlockValue.BooleanVector(set.Available);
        var countsValue = MathBlockValue.Vector(counts);
        var values = SequenceOps.Operation(name, false).Evaluate(SequenceOps.Inputs(name, false, series, availability, countsValue, parameter.First, parameter.Second));
        var flags = SequenceOps.Operation(name, true).Evaluate(SequenceOps.Inputs(name, true, series, availability, countsValue, parameter.First, parameter.Second));
        var label = string.Create(CultureInfo.InvariantCulture, $"{name} n={counts.Length} {parameter.Label}");
        if (!values.IsValid || !flags.IsValid)
            failures.Add(label + ": the call was invalid.");
        else if (values.AsVector().Count != counts.Length || flags.AsBooleanVector().Count != counts.Length)
            failures.Add(label + ": the output length is not n.");
    }

    private static void CheckInvalid(string name, ProofSet set, double[] counts, ProofParameter parameter, List<string> failures)
    {
        var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
        var availability = MathBlockValue.BooleanVector(set.Available);
        var countsValue = MathBlockValue.Vector(counts);
        var values = SequenceOps.Operation(name, false).Evaluate(SequenceOps.Inputs(name, false, series, availability, countsValue, parameter.First, parameter.Second));
        var flags = SequenceOps.Operation(name, true).Evaluate(SequenceOps.Inputs(name, true, series, availability, countsValue, parameter.First, parameter.Second));
        var label = string.Create(CultureInfo.InvariantCulture, $"{name} {parameter.Label}");
        if (values.IsValid || flags.IsValid)
            failures.Add(label + ": the call was valid.");
        else if (values.Type.Kind != MathBlockValueKind.Vector || flags.Type.Kind != MathBlockValueKind.BooleanVector)
            failures.Add(label + ": the invalid value has the wrong type.");
    }

    private static void CheckMismatch(string name, ProofSet set, double[] counts, ProofParameter parameter, List<string> failures)
    {
        var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
        var availability = MathBlockValue.BooleanVector(set.Available);
        var shorter = MathBlockValue.Vector(counts[..^1]);
        var shortAvailability = MathBlockValue.BooleanVector(set.Available[..^1]);
        for (var sibling = 0; sibling < 2; sibling++)
        {
            var operation = SequenceOps.Operation(name, sibling == 1);
            var withCounts = SequenceOps.Inputs(name, sibling == 1, series, availability, shorter, parameter.First, parameter.Second);
            var withAvailability = SequenceOps.Inputs(name, sibling == 1, series, shortAvailability, MathBlockValue.Vector(counts), parameter.First, parameter.Second);
            if (!Rejects(operation, withCounts) || !Rejects(operation, withAvailability))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{operation.Identity}: series of different lengths were accepted."));
        }
    }

    // A length mismatch is either refused by the type rule with an InvalidOperationException or gives an invalid value.
    private static bool Rejects(MathBlockOperation operation, MathBlockValue[] inputs)
    {
        try
        {
            return !operation.Evaluate(inputs).IsValid;
        }
        catch (InvalidOperationException)
        {
            return true;
        }
    }
}
