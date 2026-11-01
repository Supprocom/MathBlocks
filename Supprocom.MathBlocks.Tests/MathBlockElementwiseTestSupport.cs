using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

// The elementwise forms' own internal registry (the same instances MathBlockCatalog.Standard registers), reached
// by reflection, as the window tests do.
internal static class MathBlockElementwiseTestSupport
{
    private static readonly Lazy<MathBlockRegistry> elementwise = new(() => (MathBlockRegistry)typeof(MathBlockCatalog)
        .GetProperty("Elementwise", BindingFlags.NonPublic | BindingFlags.Static)!
        .GetValue(null)!);

    // Values that sit on the edges of the scalar domains: signed zeros, subnormals, the smallest normal, the unit
    // interval edges and their neighbours, integers around the factorial limit, the exponential overflow and
    // underflow thresholds, and the largest finite magnitudes.
    private static readonly double[] EdgeValues =
    [
        0d, double.NegativeZero, double.Epsilon, -double.Epsilon, 1e-310d, -1e-310d, 2.2250738585072014E-308d,
        -2.2250738585072014E-308d, 1e-300d, 1d, -1d, 0.5d, -0.5d, 1.5d, -1.5d, 2.5d, -2.5d, 2d, -2d, 3d,
        0.9999999999999999d, 1.0000000000000002d, -0.9999999999999999d, -1.0000000000000002d,
        Math.PI / 2d, Math.PI, -Math.PI, 10d, 170d, 171d, 709.78d, 710d, -745.2d, -746d, 1e15d,
        4503599627370495.5d, 1e200d, -1e200d, double.MaxValue, -double.MaxValue
    ];

    // The 41 sources of design section 5, in catalog order.
    public static readonly string[] SourceIdentifiers =
    [
        "combinatorics.ballot-count", "combinatorics.binomial-coefficient", "combinatorics.factorial",
        "probability.normal-cdf", "probability.poisson-cdf", "probability.poisson-pmf",
        "scalar.arc-cosine", "scalar.arc-sine", "scalar.arc-tangent-2", "scalar.arc-tangent",
        "scalar.binary-logarithm", "scalar.ceiling", "scalar.clamp", "scalar.common-logarithm", "scalar.cosine",
        "scalar.cube-root", "scalar.cube", "scalar.floor", "scalar.hyperbolic-cosine", "scalar.hyperbolic-sine",
        "scalar.hyperbolic-tangent", "scalar.inverse-hyperbolic-cosine", "scalar.inverse-hyperbolic-sine",
        "scalar.inverse-hyperbolic-tangent", "scalar.log-one-plus", "scalar.logistic", "scalar.logit",
        "scalar.maximum", "scalar.minimum", "scalar.modulo", "scalar.negate", "scalar.reciprocal", "scalar.round",
        "scalar.sine", "scalar.softplus", "scalar.tangent", "scalar.truncate",
        "special.beta", "special.error-function", "special.log-gamma", "special.regularized-incomplete-beta"
    ];

    public static MathBlockRegistry Elementwise => elementwise.Value;

    public static MathBlockOperation Form(string source) => Elementwise.Get($"elementwise.{source}");

    public static MathBlockOperation Validity(string source) => Elementwise.Get($"elementwise-valid.{source}");

    public static int SourceArity(string source) => MathBlockCatalog.Standard.Get(source).Arity;

    // Every way to choose vector or scalar per argument with at least one vector; bit k set means argument k is a
    // vector.
    public static IEnumerable<int> BroadcastMasks(string source)
    {
        var arity = SourceArity(source);
        for (var mask = 1; mask < 1 << arity; mask++)
            yield return mask;
    }

    public static string DescribeMask(string source, int mask)
    {
        var arity = SourceArity(source);
        return string.Join(',', Enumerable.Range(0, arity).Select(index => (mask >> index & 1) != 0 ? "V" : "S"));
    }

    // Builds seeded source arguments: argument k is a vector of count rows when bit k of mask is set, otherwise
    // one broadcast scalar. Values mix the edge list, ordinary reals, the unit interval, small integers, wide
    // magnitudes and tiny magnitudes, so rows cover computed results and source-invalid results.
    public static MathBlockValue[] CreateArguments(string source, int count, int mask, int seed)
    {
        var random = new Random(seed);
        var arity = SourceArity(source);
        var rows = new double[arity][];
        for (var index = 0; index < arity; index++)
        {
            var length = (mask >> index & 1) != 0 ? count : 1;
            rows[index] = new double[length];
            for (var row = 0; row < length; row++)
                rows[index][row] = Draw(random);
        }

        var arguments = new MathBlockValue[arity];
        for (var index = 0; index < arity; index++)
        {
            arguments[index] = (mask >> index & 1) != 0
                ? MathBlockValue.Vector(rows[index])
                : MathBlockValue.Scalar(rows[index][0]);
        }
        return arguments;
    }

    // Returns a copy of the arguments with every vector row for which perturbRow holds redrawn from the same value
    // mix. Scalar arguments stay fixed, so unperturbed rows keep their bits.
    public static MathBlockValue[] Perturb(MathBlockValue[] arguments, Func<int, bool> perturbRow, Random random)
    {
        var rows = new double[arguments.Length][];
        for (var index = 0; index < arguments.Length; index++)
        {
            if (arguments[index].Type.Kind != MathBlockValueKind.Vector)
            {
                rows[index] = [arguments[index].AsScalar()];
                continue;
            }
            rows[index] = arguments[index].AsVector().ToArray();
            for (var row = 0; row < rows[index].Length; row++)
                if (perturbRow(row))
                    rows[index][row] = Draw(random);
        }
        var result = new MathBlockValue[arguments.Length];
        for (var index = 0; index < arguments.Length; index++)
            result[index] = arguments[index].Type.Kind == MathBlockValueKind.Vector
                ? MathBlockValue.Vector(rows[index], arguments[index].Type.Unit)
                : arguments[index];
        return result;
    }

    private static double Draw(Random random)
    {
        var category = random.Next(20);
        return category switch
        {
            < 5 => EdgeValues[random.Next(EdgeValues.Length)],
            < 10 => random.NextDouble() * 6d - 3d,
            < 13 => random.NextDouble(),
            < 16 => random.Next(-2, 13),
            < 18 => (random.Next(2) == 0 ? -1d : 1d) * Math.Pow(10d, random.NextDouble() * 600d - 300d),
            _ => (random.Next(2) == 0 ? -1d : 1d) * random.NextDouble() * 4e-308d
        };
    }

    public static int Count(MathBlockValue[] arguments) =>
        arguments.First(argument => argument.Type.Kind == MathBlockValueKind.Vector).AsVector().Count;

    // Row i of the reference is the Standard source operation on fresh scalars: row i of each vector argument and
    // each scalar argument as it is. It does not use the elementwise lift.
    public static (bool[] Valid, double[] Values) Reference(string source, MathBlockValue[] arguments)
    {
        var operation = MathBlockCatalog.Standard.Get(source);
        var count = Count(arguments);
        var valid = new bool[count];
        var values = new double[count];
        var vectors = arguments.Select(argument =>
            argument.Type.Kind == MathBlockValueKind.Vector ? argument.AsVector().ToArray() : null).ToArray();
        Parallel.For(0, count, new ParallelOptions { MaxDegreeOfParallelism = 4 }, row =>
        {
            var scalars = new MathBlockValue[arguments.Length];
            for (var index = 0; index < scalars.Length; index++)
            {
                scalars[index] = vectors[index] is { } vector
                    ? MathBlockValue.Scalar(vector[row], arguments[index].Type.Unit)
                    : arguments[index];
            }
            var result = operation.Evaluate(scalars);
            valid[row] = result.IsValid;
            if (result.IsValid)
                values[row] = result.AsScalar();
        });
        return (valid, values);
    }

    // Compares a form and its sibling with the reference row by row, bit for bit, and returns readable failures.
    public static List<string> Compare(
        string label,
        double fill,
        MathBlockValue form,
        MathBlockValue validity,
        (bool[] Valid, double[] Values) reference)
    {
        var failures = new List<string>();
        if (!form.IsValid || !validity.IsValid)
        {
            failures.Add($"{label}: whole output invalid ({form.InvalidReason ?? validity.InvalidReason}).");
            return failures;
        }
        var values = form.AsVector();
        var flags = validity.AsBooleanVector();
        if (values.Count != reference.Values.Length || flags.Count != reference.Values.Length)
        {
            failures.Add($"{label}: length {values.Count}/{flags.Count}, expected {reference.Values.Length}.");
            return failures;
        }
        for (var row = 0; row < reference.Values.Length && failures.Count < 8; row++)
        {
            var expected = reference.Valid[row] ? reference.Values[row] : fill;
            if (BitConverter.DoubleToInt64Bits(values[row]) != BitConverter.DoubleToInt64Bits(expected))
            {
                failures.Add($"{label} row {row}: value {values[row]:R}, expected {expected:R} " +
                             $"(source {(reference.Valid[row] ? "valid" : "invalid")}).");
            }
            if (flags[row] != reference.Valid[row])
                failures.Add($"{label} row {row}: validity {flags[row]}, expected {reference.Valid[row]}.");
        }
        return failures;
    }
}
