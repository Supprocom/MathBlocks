namespace Supprocom.MathBlocks.Tests;

/// <summary>The inputs that the CoreCLR contract tests and the CUDA parity test of the prefix difference share.</summary>
internal static class PrefixDifferenceCases
{
    internal const string Form = "sequence.prefix-difference-over-offsets@1";
    internal const string Validity = "sequence.prefix-difference-over-offsets-valid@1";
    internal const double Fill = -9d;

    internal static MathBlockOperation Operation(string identity) =>
        MathBlockCatalog.Standard.Get(identity[..identity.IndexOf('@', StringComparison.Ordinal)]);

    // The inputs of the form: values, availability, counts, start, end and fill.
    internal static MathBlockValue[] FormInputs(double[] values, bool[] available, double[] counts, double start, double end) =>
    [
        MathBlockValue.Vector(values),
        MathBlockValue.BooleanVector(available),
        MathBlockValue.Vector(counts),
        MathBlockValue.Scalar(start),
        MathBlockValue.Scalar(end),
        MathBlockValue.Scalar(Fill)
    ];

    internal static MathBlockValue[] ValidityInputs(MathBlockValue[] formInputs) => formInputs[..5];

    internal static double[] Sequence(int length, double first = 1d)
    {
        var result = new double[length];
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
        yield return ("invalid-row-inside", FormInputs(Sequence(5), [true, true, false, true, true], Sequence(5, 0d), -1d, 0d));
        yield return ("invalid-row-before", FormInputs(Sequence(5), [false, true, true, true, true], Sequence(5, 0d), 0d, 1d));
        yield return ("segments", FormInputs([1d, 2d, 3d, 10d, 20d, 30d], All(6), [0d, 1d, 2d, 0d, 1d, 2d], 0d, 1d));
        yield return ("segment-backward", FormInputs([1d, 2d, 3d, 10d, 20d, 30d], All(6), [0d, 1d, 2d, 0d, 1d, 2d], -1d, 0d));
        yield return ("first-row-count-nonzero", FormInputs(Sequence(4), All(4), [3d, 4d, 0d, 1d], 0d, 1d));
        yield return ("both-sides", FormInputs(Sequence(7), All(7), Sequence(7, 0d), -2d, 1d));
        yield return ("tail", FormInputs(Sequence(5), All(5), Sequence(5, 0d), 1d, 2d));
        yield return ("single-row", FormInputs([1e16, 1d, 1d, 1d], All(4), Sequence(4, 0d), 0d, 0d));
        yield return ("prefix-overflow", FormInputs([1.5e308, 1.5e308, 1d, 2d, 3d], All(5), Sequence(5, 0d), 0d, 0d));
        yield return ("difference-overflow", FormInputs([-1.7e308, 1.7e308, 1.7e308], All(3), Sequence(3, 0d), 1d, 2d));
        yield return ("window-outside-series", FormInputs(Sequence(4), All(4), Sequence(4, 0d), 100d, 200d));
        yield return ("negative-zero", FormInputs([-0d, -0d, 0d], All(3), Sequence(3, 0d), 0d, 1d));
        yield return ("all-unavailable", FormInputs(Sequence(4), All(4, false), Sequence(4, 0d), 0d, 1d));
        yield return ("empty", FormInputs([], [], [], 0d, 0d));
        yield return ("one-row", FormInputs([7d], [true], [0d], 0d, 0d));
        yield return ("long-window", FormInputs(Sequence(20, 0.1d), All(20), Sequence(20, 0d), -3d, 5d));
    }

    // Calls that are invalid as a whole.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> WholeCallInvalid()
    {
        var values = Sequence(5);
        var counts = Sequence(5, 0d);
        yield return ("start-after-end", FormInputs(values, All(5), counts, 1d, 0d));
        yield return ("start-not-integer", FormInputs(values, All(5), counts, 0.5d, 1d));
        yield return ("end-not-integer", FormInputs(values, All(5), counts, 0d, 1.5d));
        yield return ("count-not-integer", FormInputs(values, All(5), [0d, 1d, 1.5d, 3d, 4d], 0d, 1d));
        yield return ("count-negative", FormInputs(values, All(5), [0d, 1d, -2d, 3d, 4d], 0d, 1d));
    }

    // Series of different lengths: the type rule rejects them while it knows both lengths, as it does for vector.add.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> LengthMismatch()
    {
        var values = Sequence(5);
        var counts = Sequence(5, 0d);
        yield return ("counts-shorter", FormInputs(values, All(5), [0d, 1d, 2d], 0d, 1d));
        yield return ("availability-longer", FormInputs(values, All(6), counts, 0d, 1d));
    }

    // An empty series has no known length, so the type rule accepts it beside a longer one and the call is invalid as a whole.
    internal static IEnumerable<(string Name, MathBlockValue[] Inputs)> EmptyBesideLonger()
    {
        var values = Sequence(5);
        yield return ("counts-empty", FormInputs(values, All(5), [], 0d, 1d));
        yield return ("availability-empty", FormInputs(values, [], Sequence(5, 0d), 0d, 1d));
    }

    // The sum of the window t + start .. t + end added left to right, or null when a row is outside the series or
    // unavailable. The series is one segment. This is the sum-over-offsets rule, written out for the clean-window comparison.
    internal static double? DirectWindowSum(double[] values, bool[] available, int row, int start, int end)
    {
        var low = row + start;
        var high = row + end;
        if (low < 0 || high >= values.Length)
            return null;
        var sum = 0d;
        for (var index = low; index <= high; index++)
        {
            if (!available[index])
                return null;
            sum += values[index];
        }

        return sum;
    }
}
