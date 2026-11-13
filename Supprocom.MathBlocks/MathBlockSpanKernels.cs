using System.Collections.Concurrent;

namespace Supprocom.MathBlocks;

// Non-allocating CoreCLR kernels for vector-to-vector operations. A kernel serves only the common case: every input
// valid, vector and scalar inputs dimensionless, and equal non-zero vector lengths. It returns false, having written
// nothing, for anything else, and the caller then takes the allocating Evaluate, so every outcome (including a type
// exception or an invalid result of a given type) stays that of Evaluate. In the common case each kernel applies the
// same function to the same doubles as the operation's own evaluator, so the rows are bit-identical.
internal static class MathBlockSpanKernels
{
    internal delegate bool Kernel(ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid);

    internal delegate bool RowKernel(ReadOnlySpan<MathBlockValue> inputs, Span<double> output, Span<bool> rowValid, out int rows);

    private static readonly ConcurrentDictionary<string, Kernel?> cache = new(StringComparer.Ordinal);
    private static readonly ConcurrentDictionary<string, RowKernel?> rowCache = new(StringComparer.Ordinal);

    internal static Kernel? Find(string identity) =>
        cache.TryGetValue(identity, out var kernel) ? kernel : cache.GetOrAdd(identity, Create);

    // The elementwise form with its per-row validity: row i holds the form's value (the fill where the row is not
    // computed) and rowValid[i] the validity sibling's flag.
    internal static RowKernel? FindRows(string identity) =>
        rowCache.TryGetValue(identity, out var kernel) ? kernel : rowCache.GetOrAdd(identity, CreateRows);

    private static Kernel? Create(string identity) => identity switch
    {
        "vector.absolute@1" => Unary(static x => Math.Abs(x)),
        "vector.sign@1" => Unary(static x => Math.Sign(x)),
        "vector.positive-part@1" => Unary(static x => Math.Max(x, 0d)),
        "vector.square@1" => Unary(static x => x * x),
        "vector.square-root@1" => Unary(static x => Math.Sqrt(x)),
        "vector.exponential@1" => Unary(MathBlockScalar.Exponential),
        "vector.natural-logarithm@1" => Unary(MathBlockScalar.NaturalLogarithm),
        "vector.add@1" => Arithmetic(MathBlockSimd.Add),
        "vector.subtract@1" => Arithmetic(MathBlockSimd.Subtract),
        "vector.multiply@1" => Arithmetic(MathBlockSimd.Multiply),
        "vector.divide@1" => Arithmetic(MathBlockSimd.Divide),
        "vector.scale@1" => WithScalar(static (x, s) => x * s),
        "vector.add-scalar@1" => WithScalar(static (x, s) => x + s),
        "vector.power@1" => WithScalar(MathBlockScalar.Power),
        "vector.greater-than@1" => Comparison(static (a, b) => a > b),
        "vector.less-than@1" => Comparison(static (a, b) => a < b),
        "vector.equal@1" => Comparison(static (a, b) => a == b),
        "boolean-vector.and@1" => BooleanBinary(static (a, b) => a && b),
        "boolean-vector.or@1" => BooleanBinary(static (a, b) => a || b),
        "boolean-vector.xor@1" => BooleanBinary(static (a, b) => a != b),
        "boolean-vector.not@1" => BooleanNot(),
        "vector.select@1" => Select(),
        _ => CreateElementwise(identity)
    };

    // A vector input of the common case: valid, a vector, dimensionless.
    private static bool TryVector(in MathBlockValue value, out ReadOnlySpan<double> span)
    {
        if (value.IsValid && value.Type.Kind == MathBlockValueKind.Vector && value.Type.Unit.IsDimensionless)
        {
            span = value.AsVector().Span;
            return true;
        }

        span = default;
        return false;
    }

    private static bool TryScalar(in MathBlockValue value, out double scalar)
    {
        if (value.IsValid && value.Type.Kind == MathBlockValueKind.Scalar && value.Type.Unit.IsDimensionless)
        {
            scalar = value.AsScalar();
            return true;
        }

        scalar = 0d;
        return false;
    }

    private static bool TryFlags(in MathBlockValue value, out ReadOnlySpan<bool> span)
    {
        if (value.IsValid && value.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            span = value.AsBooleanVector().Span;
            return true;
        }

        span = default;
        return false;
    }

    private static void RequireLength(Span<double> output, int rows)
    {
        if (output.Length < rows)
        {
            throw new ArgumentException(
                string.Create(System.Globalization.CultureInfo.InvariantCulture, $"The output span needs {rows} elements; it has {output.Length}."),
                nameof(output));
        }
    }

    private static Kernel Unary(Func<double, double> function) =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 1 || !TryVector(in inputs[0], out var values) || values.Length == 0)
                return false;
            rows = values.Length;
            RequireLength(output, rows);
            for (var index = 0; index < values.Length; index++)
                output[index] = function(values[index]);
            valid = MathBlockSimd.AllFinite(output[..rows]);
            return true;
        };

    private static Kernel Arithmetic(Action<ReadOnlySpan<double>, ReadOnlySpan<double>, Span<double>> block) =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 2 || !TryVector(in inputs[0], out var left) || !TryVector(in inputs[1], out var right) ||
                left.Length == 0 || left.Length != right.Length)
            {
                return false;
            }

            rows = left.Length;
            RequireLength(output, rows);
            block(left, right, output[..rows]);
            valid = MathBlockSimd.AllFinite(output[..rows]);
            return true;
        };

    private static Kernel WithScalar(Func<double, double, double> function) =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 2 || !TryVector(in inputs[0], out var values) || !TryScalar(in inputs[1], out var scalar) ||
                values.Length == 0)
            {
                return false;
            }

            rows = values.Length;
            RequireLength(output, rows);
            for (var index = 0; index < values.Length; index++)
                output[index] = function(values[index], scalar);
            valid = MathBlockSimd.AllFinite(output[..rows]);
            return true;
        };

    private static Kernel Comparison(Func<double, double, bool> function) =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 2 || !TryVector(in inputs[0], out var left) || !TryVector(in inputs[1], out var right) ||
                left.Length == 0 || left.Length != right.Length)
            {
                return false;
            }

            rows = left.Length;
            RequireLength(output, rows);
            for (var index = 0; index < rows; index++)
                output[index] = function(left[index], right[index]) ? 1d : 0d;
            valid = true;
            return true;
        };

    private static Kernel BooleanBinary(Func<bool, bool, bool> function) =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 2 || !TryFlags(in inputs[0], out var left) || !TryFlags(in inputs[1], out var right) ||
                left.Length == 0 || left.Length != right.Length)
            {
                return false;
            }

            rows = left.Length;
            RequireLength(output, rows);
            for (var index = 0; index < rows; index++)
                output[index] = function(left[index], right[index]) ? 1d : 0d;
            valid = true;
            return true;
        };

    private static Kernel BooleanNot() =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 1 || !TryFlags(in inputs[0], out var flags) || flags.Length == 0)
                return false;
            rows = flags.Length;
            RequireLength(output, rows);
            for (var index = 0; index < rows; index++)
                output[index] = flags[index] ? 0d : 1d;
            valid = true;
            return true;
        };

    private static Kernel Select() =>
        (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != 3 || !TryFlags(in inputs[0], out var condition) ||
                !TryVector(in inputs[1], out var whenTrue) || !TryVector(in inputs[2], out var whenFalse) ||
                condition.Length == 0 || condition.Length != whenTrue.Length || whenTrue.Length != whenFalse.Length)
            {
                return false;
            }

            rows = condition.Length;
            RequireLength(output, rows);
            for (var index = 0; index < rows; index++)
                output[index] = condition[index] ? whenTrue[index] : whenFalse[index];
            valid = true;
            return true;
        };

    // elementwise.<source> and elementwise-valid.<source>: row i is the source's own kernel on row i, and the fill
    // (the last argument of the form) where the result is not finite or the kernel raises one of the three exceptions
    // Evaluate turns into an invalid row. The validity sibling writes 1 for a computed row and 0 otherwise.
    private static Kernel? CreateElementwise(string identity)
    {
        const string formPrefix = "elementwise.";
        const string validPrefix = "elementwise-valid.";
        var validity = identity.StartsWith(validPrefix, StringComparison.Ordinal);
        if (!validity && !identity.StartsWith(formPrefix, StringComparison.Ordinal))
            return null;
        var sourceIdentity = identity[(validity ? validPrefix.Length : formPrefix.Length)..];
        MathBlockOperation? source = null;
        foreach (var candidate in MathBlockCatalog.Standard.Operations)
        {
            if (string.Equals(candidate.Identity, sourceIdentity, StringComparison.Ordinal))
            {
                source = candidate;
                break;
            }
        }

        if (source is null || source.Arity is not (1 or 2) ||
            (source.Arity == 1 && source.UnaryKernel is null) || (source.Arity == 2 && source.BinaryKernel is null))
        {
            return null;
        }

        var arity = source.Arity;
        var unary = source.UnaryKernel;
        var binary = source.BinaryKernel;
        var formArity = validity ? arity : arity + 1;
        return (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (inputs.Length != formArity)
                return false;
            if (!TryArgument(in inputs[0], out var first, out var constantFirst, out var firstIsVector))
                return false;
            ReadOnlySpan<double> second = default;
            var constantSecond = 0d;
            var secondIsVector = false;
            if (arity == 2 && !TryArgument(in inputs[1], out second, out constantSecond, out secondIsVector))
                return false;
            var fill = 0d;
            if (!validity && !TryScalar(in inputs[arity], out fill))
                return false;
            var count = firstIsVector ? first.Length : secondIsVector ? second.Length : -1;
            if (count <= 0 || (firstIsVector && secondIsVector && first.Length != second.Length))
                return false;
            rows = count;
            RequireLength(output, rows);
            var row = 0;
            while (row < count)
            {
                try
                {
                    for (; row < count; row++)
                    {
                        var x = firstIsVector ? first[row] : constantFirst;
                        var y = secondIsVector ? second[row] : constantSecond;
                        var result = arity == 1 ? unary!(x) : binary!(x, y);
                        var computed = Math.IsFinite(result);
                        output[row] = validity ? (computed ? 1d : 0d) : (computed ? result : fill);
                    }
                }
                catch (Exception exception) when (exception is ArithmeticException or ArgumentOutOfRangeException or IndexOutOfRangeException)
                {
                    output[row] = validity ? 0d : fill;
                    row++;
                }
            }

            valid = true;
            return true;
        };
    }

    private static RowKernel? CreateRows(string identity)
    {
        const string formPrefix = "elementwise.";
        if (!identity.StartsWith(formPrefix, StringComparison.Ordinal))
            return null;
        var source = FindSource(identity[formPrefix.Length..]);
        if (source is null)
            return null;
        var arity = source.Arity;
        var unary = source.UnaryKernel;
        var binary = source.BinaryKernel;
        return (ReadOnlySpan<MathBlockValue> inputs, Span<double> output, Span<bool> rowValid, out int rows) =>
        {
            rows = 0;
            if (inputs.Length != arity + 1)
                return false;
            if (!TryArgument(in inputs[0], out var first, out var constantFirst, out var firstIsVector))
                return false;
            ReadOnlySpan<double> second = default;
            var constantSecond = 0d;
            var secondIsVector = false;
            if (arity == 2 && !TryArgument(in inputs[1], out second, out constantSecond, out secondIsVector))
                return false;
            if (!TryScalar(in inputs[arity], out var fill))
                return false;
            var count = firstIsVector ? first.Length : secondIsVector ? second.Length : -1;
            if (count <= 0 || (firstIsVector && secondIsVector && first.Length != second.Length))
                return false;
            rows = count;
            RequireLength(output, rows);
            if (rowValid.Length < rows)
            {
                throw new ArgumentException(
                    string.Create(System.Globalization.CultureInfo.InvariantCulture, $"The row validity span needs {rows} elements; it has {rowValid.Length}."),
                    nameof(rowValid));
            }

            var row = 0;
            while (row < count)
            {
                try
                {
                    for (; row < count; row++)
                    {
                        var x = firstIsVector ? first[row] : constantFirst;
                        var y = secondIsVector ? second[row] : constantSecond;
                        var result = arity == 1 ? unary!(x) : binary!(x, y);
                        var computed = Math.IsFinite(result);
                        output[row] = computed ? result : fill;
                        rowValid[row] = computed;
                    }
                }
                catch (Exception exception) when (exception is ArithmeticException or ArgumentOutOfRangeException or IndexOutOfRangeException)
                {
                    output[row] = fill;
                    rowValid[row] = false;
                    row++;
                }
            }

            return true;
        };
    }

    private static MathBlockOperation? FindSource(string sourceIdentity)
    {
        foreach (var candidate in MathBlockCatalog.Standard.Operations)
        {
            if (string.Equals(candidate.Identity, sourceIdentity, StringComparison.Ordinal) &&
                candidate.Arity is 1 or 2 &&
                ((candidate.Arity == 1 && candidate.UnaryKernel is not null) || (candidate.Arity == 2 && candidate.BinaryKernel is not null)))
            {
                return candidate;
            }
        }

        return null;
    }

    private static bool TryArgument(in MathBlockValue value, out ReadOnlySpan<double> span, out double constant, out bool isVector)
    {
        span = default;
        constant = 0d;
        isVector = TryVector(in value, out span);
        return isVector || TryScalar(in value, out constant);
    }
}
