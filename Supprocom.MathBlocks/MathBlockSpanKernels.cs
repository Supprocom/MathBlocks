using System.Collections.Concurrent;

namespace Supprocom.MathBlocks;

// Non-allocating CoreCLR kernels for vector-to-vector operations. A kernel serves only the common case: every input
// valid, with finite data, vector and scalar inputs dimensionless, and equal non-zero vector lengths. It returns false,
// having written nothing, for anything else, and the caller then takes the allocating Evaluate, so every outcome
// (including a type exception or an invalid result of a given type) stays that of Evaluate. In the common case each
// kernel applies the same function to the same doubles as the operation's own evaluator, so the rows are bit-identical.
// A kernel reads its operands as span arguments, so one kernel serves an evaluation on values and one on caller spans.
internal static class MathBlockSpanKernels
{
    internal delegate bool Kernel(in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid);

    internal delegate bool RowKernel(in MathBlockSpanOperands operands, Span<double> output, Span<bool> rowValid, out int rows);

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
        "vector.standardize@1" => Standardize(),
        "vector.repeat@1" => Repeat(),
        _ => CreateElementwise(identity)
    };

    // A vector input of the common case: a vector of finite numbers, dimensionless.
    private static bool TryVector(in MathBlockSpanArgument argument, out ReadOnlySpan<double> span)
    {
        if (argument.Kind == MathBlockValueKind.Vector && argument.Unit.IsDimensionless && argument.HoldsFiniteData())
        {
            span = argument.Values;
            return true;
        }

        span = default;
        return false;
    }

    private static bool TryScalar(in MathBlockSpanArgument argument, out double scalar)
    {
        if (argument.Kind == MathBlockValueKind.Scalar && argument.Unit.IsDimensionless && argument.HoldsFiniteData())
        {
            scalar = argument.ScalarValue;
            return true;
        }

        scalar = 0d;
        return false;
    }

    private static bool TryFlags(in MathBlockSpanArgument argument, out ReadOnlySpan<bool> span)
    {
        if (argument.Kind == MathBlockValueKind.BooleanVector)
        {
            span = argument.Flags;
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
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 1 || !TryVector(in operands[0], out var values) || values.Length == 0)
                return false;
            rows = values.Length;
            RequireLength(output, rows);
            for (var index = 0; index < values.Length; index++)
                output[index] = function(values[index]);
            valid = MathBlockSimd.AllFinite(output[..rows]);
            return true;
        };

    private static Kernel Arithmetic(Action<ReadOnlySpan<double>, ReadOnlySpan<double>, Span<double>> block) =>
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 2 || !TryVector(in operands[0], out var left) || !TryVector(in operands[1], out var right) ||
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
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 2 || !TryVector(in operands[0], out var values) || !TryScalar(in operands[1], out var scalar) ||
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
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 2 || !TryVector(in operands[0], out var left) || !TryVector(in operands[1], out var right) ||
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
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 2 || !TryFlags(in operands[0], out var left) || !TryFlags(in operands[1], out var right) ||
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
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 1 || !TryFlags(in operands[0], out var flags) || flags.Length == 0)
                return false;
            rows = flags.Length;
            RequireLength(output, rows);
            for (var index = 0; index < rows; index++)
                output[index] = flags[index] ? 0d : 1d;
            valid = true;
            return true;
        };

    private static Kernel Select() =>
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 3 || !TryFlags(in operands[0], out var condition) ||
                !TryVector(in operands[1], out var whenTrue) || !TryVector(in operands[2], out var whenFalse) ||
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

    // The operation's own order of operations: the compensated sum, the mean, the variance of the differences, and the
    // quotient of each difference by the deviation, which is NaN where the variance overflowed.
    private static Kernel Standardize() =>
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != 1 || !TryVector(in operands[0], out var values) || values.Length == 0)
                return false;
            rows = values.Length;
            RequireLength(output, rows);
            var sum = 0d;
            var correction = 0d;
            for (var index = 0; index < values.Length; index++)
            {
                var value = values[index];
                var next = sum + value;
                correction += Math.Abs(sum) >= Math.Abs(value) ? sum - next + value : value - next + sum;
                sum = next;
            }

            var mean = (sum + correction) / values.Length;
            var variance = 0d;
            for (var index = 0; index < values.Length; index++)
            {
                var difference = values[index] - mean;
                variance += difference * difference;
            }

            variance /= values.Length;
            var deviation = Math.IsFinite(variance) ? Math.Sqrt(variance) : Math.NaN;
            for (var index = 0; index < values.Length; index++)
                output[index] = (values[index] - mean) / deviation;
            valid = MathBlockSimd.AllFinite(output[..rows]);
            return true;
        };

    // vector.repeat@1: the value, count times. A count that is not a nonnegative integer, or is over the generated
    // vector limit, declines, and the allocating evaluation gives the invalid result of its declared type.
    private static Kernel Repeat() =>
        (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            ref readonly var element = ref operands[0];
            if (operands.Count != 2 || element.Kind != MathBlockValueKind.Scalar || !element.HoldsFiniteData() ||
                !TryScalar(in operands[1], out var countValue) ||
                countValue < 0d || countValue > int.MaxValue || countValue != Math.Truncate(countValue) ||
                (int)countValue > options.MaximumGeneratedVectorLength)
            {
                return false;
            }

            rows = (int)countValue;
            RequireLength(output, rows);
            output[..rows].Fill(element.ScalarValue);
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
        return (in MathBlockSpanOperands operands, MathBlockDomainOptions options, Span<double> output, out int rows, out bool valid) =>
        {
            rows = 0;
            valid = false;
            if (operands.Count != formArity)
                return false;
            if (!TryArgument(in operands[0], out var first, out var constantFirst, out var firstIsVector))
                return false;
            ReadOnlySpan<double> second = default;
            var constantSecond = 0d;
            var secondIsVector = false;
            if (arity == 2 && !TryArgument(in operands[1], out second, out constantSecond, out secondIsVector))
                return false;
            var fill = 0d;
            if (!validity && !TryScalar(in operands[arity], out fill))
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
        return (in MathBlockSpanOperands operands, Span<double> output, Span<bool> rowValid, out int rows) =>
        {
            rows = 0;
            if (operands.Count != arity + 1)
                return false;
            if (!TryArgument(in operands[0], out var first, out var constantFirst, out var firstIsVector))
                return false;
            ReadOnlySpan<double> second = default;
            var constantSecond = 0d;
            var secondIsVector = false;
            if (arity == 2 && !TryArgument(in operands[1], out second, out constantSecond, out secondIsVector))
                return false;
            if (!TryScalar(in operands[arity], out var fill))
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

    private static bool TryArgument(in MathBlockSpanArgument argument, out ReadOnlySpan<double> span, out double constant, out bool isVector)
    {
        span = default;
        constant = 0d;
        isVector = TryVector(in argument, out span);
        return isVector || TryScalar(in argument, out constant);
    }
}
