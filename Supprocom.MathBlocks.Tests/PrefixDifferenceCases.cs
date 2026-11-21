namespace Supprocom.MathBlocks.Tests;

/// <summary>The inputs that the CoreCLR contract tests and the CUDA parity test of the prefix difference share.</summary>
internal static class PrefixDifferenceCases
{
    internal const string Form = "sequence.prefix-difference-over-offsets@1";
    internal const string Validity = "sequence.prefix-difference-over-offsets-valid@1";
    internal const float Fill = -9f;

    internal static MathBlockOperation Operation(string identity) =>
        MathBlockCatalog.Standard.Get(identity[..identity.IndexOf('@', StringComparison.Ordinal)]);

    // The inputs of the form: values, availability, counts, start, end and fill.
    internal static MathBlockValue[] FormInputs(float[] values, bool[] available, float[] counts, float start, float end) =>
    [
        MathBlockValue.Vector(values),
        MathBlockValue.BooleanVector(available),
        MathBlockValue.Vector(counts),
        MathBlockValue.Scalar(start),
        MathBlockValue.Scalar(end),
        MathBlockValue.Scalar(Fill)
    ];

    internal static MathBlockValue[] ValidityInputs(MathBlockValue[] formInputs) => formInputs[..5];

    internal static float[] Sequence(int length, float first = 1f)
    {
        var result = new float[length];
        for (var row = 0; row < length; row++)
            result[row] = first + row;
        return result;
    }

    internal static bool[] All(int length, bool value = true)
    {
        var result = new bool[length];
        Array.Fill(result, value);
        return result;
    }

    // Named cases, each a valid call, for the contract tests and for the device parity test.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> Valid()
    {
        yield return ("invalid-row-inside", FormInputs(Sequence(5), [true, true, false, true, true], Sequence(5, 0f), -1f, 0f));
        yield return ("invalid-row-before", FormInputs(Sequence(5), [false, true, true, true, true], Sequence(5, 0f), 0f, 1f));
        yield return ("segments", FormInputs([1f, 2f, 3f, 10f, 20f, 30f], All(6), [0f, 1f, 2f, 0f, 1f, 2f], 0f, 1f));
        yield return ("segment-backward", FormInputs([1f, 2f, 3f, 10f, 20f, 30f], All(6), [0f, 1f, 2f, 0f, 1f, 2f], -1f, 0f));
        yield return ("first-row-count-nonzero", FormInputs(Sequence(4), All(4), [3f, 4f, 0f, 1f], 0f, 1f));
        yield return ("both-sides", FormInputs(Sequence(7), All(7), Sequence(7, 0f), -2f, 1f));
        yield return ("tail", FormInputs(Sequence(5), All(5), Sequence(5, 0f), 1f, 2f));
        yield return ("single-row", FormInputs([1e16f, 1f, 1f, 1f], All(4), Sequence(4, 0f), 0f, 0f));
        yield return ("prefix-overflow", FormInputs([3.33e38f, 3.33e38f, 1f, 2f, 3f], All(5), Sequence(5, 0f), 0f, 0f));
        yield return ("difference-overflow", FormInputs([-3.38e38f, 3.38e38f, 3.38e38f], All(3), Sequence(3, 0f), 1f, 2f));
        yield return ("window-outside-series", FormInputs(Sequence(4), All(4), Sequence(4, 0f), 100f, 200f));
        yield return ("negative-zero", FormInputs([-0f, -0f, 0f], All(3), Sequence(3, 0f), 0f, 1f));
        yield return ("all-unavailable", FormInputs(Sequence(4), All(4, false), Sequence(4, 0f), 0f, 1f));
        yield return ("empty", FormInputs([], [], [], 0f, 0f));
        yield return ("one-row", FormInputs([7f], [true], [0f], 0f, 0f));
        yield return ("long-window", FormInputs(Sequence(20, 0.1f), All(20), Sequence(20, 0f), -3f, 5f));
    }

    // Calls that are invalid as a whole.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> WholeCallInvalid()
    {
        var values = Sequence(5);
        var counts = Sequence(5, 0f);
        yield return ("start-after-end", FormInputs(values, All(5), counts, 1f, 0f));
        yield return ("start-not-integer", FormInputs(values, All(5), counts, 0.5f, 1f));
        yield return ("end-not-integer", FormInputs(values, All(5), counts, 0f, 1.5f));
        yield return ("count-not-integer", FormInputs(values, All(5), [0f, 1f, 1.5f, 3f, 4f], 0f, 1f));
        yield return ("count-negative", FormInputs(values, All(5), [0f, 1f, -2f, 3f, 4f], 0f, 1f));
    }

    // Series of different lengths: the type rule rejects them while it knows both lengths, as it does for vector.add.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> LengthMismatch()
    {
        var values = Sequence(5);
        var counts = Sequence(5, 0f);
        yield return ("counts-shorter", FormInputs(values, All(5), [0f, 1f, 2f], 0f, 1f));
        yield return ("availability-longer", FormInputs(values, All(6), counts, 0f, 1f));
    }

    // An empty series has no known length, so the type rule accepts it beside a longer one and the call is invalid as a whole.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> EmptyBesideLonger()
    {
        var values = Sequence(5);
        yield return ("counts-empty", FormInputs(values, All(5), [], 0f, 1f));
        yield return ("availability-empty", FormInputs(values, [], Sequence(5, 0f), 0f, 1f));
    }

    // The sum of the window t + start .. t + end added left to right, or null when a row is outside the series or
    // unavailable. The series is one segment. This is the sum-over-offsets rule, written out for the clean-window comparison.
    internal static float? DirectWindowSum(float[] values, bool[] available, int row, int start, int end)
    {
        var low = row + start;
        var high = row + end;
        if (low < 0 || high >= values.Length)
            return null;
        var sum = 0f;
        for (var index = low; index <= high; index++)
        {
            if (!available[index])
                return null;
            sum += values[index];
        }

        return sum;
    }
}
