using System.Globalization;

namespace Supprocom.MathBlocks;

// The CoreCLR evaluation into caller-owned spans. An operation with a span kernel runs it on the operands as they are, with no
// type resolution, value or array; every other call evaluates on values and copies the rows.
public sealed partial class MathBlockOperation
{
    private MathBlockSpanKernels.Kernel? spanKernel;
    private MathBlockSpanKernels.RowKernel? spanRowKernel;
    private bool spanKernelResolved;
    private bool spanRowKernelResolved;

    /// <summary>Evaluates a one-argument vector-to-vector operation on CoreCLR into a caller-owned span without allocating in the common case.</summary>
    /// <param name="a">The argument.</param>
    /// <param name="output">The span that receives the rows; it holds the rows of a valid result, and its contents are unspecified for an invalid one.</param>
    /// <param name="domainOptions">The domain limits of the evaluation.</param>
    /// <remarks>
    /// Rows are written as doubles; a Boolean vector writes 1 and 0. The result equals the one of
    /// <see cref="Evaluate(IReadOnlyList{MathBlockValue}, MathBlockDomainOptions)"/> on the values that hold the arguments, bit for bit: an argument
    /// with a nonfinite element is an invalid input, and its evaluation is invalid. Operations without a span kernel, and arguments outside the
    /// common case (a unit, an empty or unequal vector), take that allocating evaluation and copy its rows.
    /// </remarks>
    /// <exception cref="ArgumentNullException"><paramref name="domainOptions"/> is null.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    /// <exception cref="ArgumentException">An argument is the default value; the number of arguments is not the arity; or the output span is shorter than the rows of the result, in which case the message names the needed length.</exception>
    public MathBlockEvaluation EvaluateCoreCLR(in MathBlockSpanArgument a, Span<double> output, MathBlockDomainOptions domainOptions)
    {
        RequireInitialized(in a, nameof(a));
        return EvaluateOperands(new MathBlockSpanOperands(in a), output, domainOptions);
    }

    /// <summary>Evaluates a two-argument vector-to-vector operation on CoreCLR into a caller-owned span without allocating in the common case.</summary>
    /// <param name="a">The first argument.</param>
    /// <param name="b">The second argument.</param>
    /// <param name="output">The span that receives the rows.</param>
    /// <param name="domainOptions">The domain limits of the evaluation.</param>
    /// <remarks>The result and the fallbacks are those of the one-argument overload; the arguments stand for the values that hold the same numbers.</remarks>
    /// <exception cref="ArgumentNullException"><paramref name="domainOptions"/> is null.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    /// <exception cref="ArgumentException">An argument is the default value; the number of arguments is not the arity; or the output span is shorter than the rows of the result, in which case the message names the needed length.</exception>
    public MathBlockEvaluation EvaluateCoreCLR(in MathBlockSpanArgument a, in MathBlockSpanArgument b, Span<double> output, MathBlockDomainOptions domainOptions)
    {
        RequireInitialized(in a, nameof(a));
        RequireInitialized(in b, nameof(b));
        return EvaluateOperands(new MathBlockSpanOperands(in a, in b), output, domainOptions);
    }

    /// <summary>Evaluates a three-argument vector-to-vector operation on CoreCLR into a caller-owned span without allocating in the common case.</summary>
    /// <param name="a">The first argument.</param>
    /// <param name="b">The second argument.</param>
    /// <param name="c">The third argument.</param>
    /// <param name="output">The span that receives the rows.</param>
    /// <param name="domainOptions">The domain limits of the evaluation.</param>
    /// <remarks>The result and the fallbacks are those of the one-argument overload; the arguments stand for the values that hold the same numbers.</remarks>
    /// <exception cref="ArgumentNullException"><paramref name="domainOptions"/> is null.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    /// <exception cref="ArgumentException">An argument is the default value; the number of arguments is not the arity; or the output span is shorter than the rows of the result, in which case the message names the needed length.</exception>
    public MathBlockEvaluation EvaluateCoreCLR(in MathBlockSpanArgument a, in MathBlockSpanArgument b, in MathBlockSpanArgument c, Span<double> output, MathBlockDomainOptions domainOptions)
    {
        RequireInitialized(in a, nameof(a));
        RequireInitialized(in b, nameof(b));
        RequireInitialized(in c, nameof(c));
        return EvaluateOperands(new MathBlockSpanOperands(in a, in b, in c), output, domainOptions);
    }

    /// <summary>Evaluates a one-argument elementwise form on CoreCLR into caller-owned spans with a validity flag per row, without allocating in the common case.</summary>
    /// <param name="a">The argument.</param>
    /// <param name="output">The span that receives the value of each row, with the fill in every row that was not computed.</param>
    /// <param name="rowValid">The span that receives the validity of each row.</param>
    /// <param name="domainOptions">The domain limits of the evaluation.</param>
    /// <remarks>
    /// <paramref name="output"/> equals the value of the form bit for bit, and <paramref name="rowValid"/> equals the validity sibling. The
    /// result is invalid only when the evaluation as a whole cannot run, such as an argument with a nonfinite element; invalid rows alone never make it so.
    /// </remarks>
    /// <exception cref="ArgumentNullException"><paramref name="domainOptions"/> is null.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    /// <exception cref="InvalidOperationException">The operation is not an <c>elementwise.*</c> form.</exception>
    /// <exception cref="ArgumentException">An argument is the default value; the number of arguments is not the arity; or a span is shorter than the rows of the result, in which case the message names the needed length.</exception>
    public MathBlockEvaluation EvaluateCoreCLR(in MathBlockSpanArgument a, Span<double> output, Span<bool> rowValid, MathBlockDomainOptions domainOptions)
    {
        RequireInitialized(in a, nameof(a));
        return EvaluateRowOperands(new MathBlockSpanOperands(in a), output, rowValid, domainOptions);
    }

    /// <summary>Evaluates a two-argument elementwise form on CoreCLR into caller-owned spans with a validity flag per row, without allocating in the common case.</summary>
    /// <param name="a">The first argument.</param>
    /// <param name="b">The second argument.</param>
    /// <param name="output">The span that receives the value of each row.</param>
    /// <param name="rowValid">The span that receives the validity of each row.</param>
    /// <param name="domainOptions">The domain limits of the evaluation.</param>
    /// <remarks>The result and the fallbacks are those of the one-argument overload; the arguments stand for the values that hold the same numbers.</remarks>
    /// <exception cref="ArgumentNullException"><paramref name="domainOptions"/> is null.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    /// <exception cref="InvalidOperationException">The operation is not an <c>elementwise.*</c> form.</exception>
    /// <exception cref="ArgumentException">An argument is the default value; the number of arguments is not the arity; or a span is shorter than the rows of the result, in which case the message names the needed length.</exception>
    public MathBlockEvaluation EvaluateCoreCLR(in MathBlockSpanArgument a, in MathBlockSpanArgument b, Span<double> output, Span<bool> rowValid, MathBlockDomainOptions domainOptions)
    {
        RequireInitialized(in a, nameof(a));
        RequireInitialized(in b, nameof(b));
        return EvaluateRowOperands(new MathBlockSpanOperands(in a, in b), output, rowValid, domainOptions);
    }

    /// <summary>Evaluates a three-argument elementwise form on CoreCLR into caller-owned spans with a validity flag per row, without allocating in the common case.</summary>
    /// <param name="a">The first argument.</param>
    /// <param name="b">The second argument.</param>
    /// <param name="c">The third argument.</param>
    /// <param name="output">The span that receives the value of each row.</param>
    /// <param name="rowValid">The span that receives the validity of each row.</param>
    /// <param name="domainOptions">The domain limits of the evaluation.</param>
    /// <remarks>The result and the fallbacks are those of the one-argument overload; the arguments stand for the values that hold the same numbers.</remarks>
    /// <exception cref="ArgumentNullException"><paramref name="domainOptions"/> is null.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    /// <exception cref="InvalidOperationException">The operation is not an <c>elementwise.*</c> form.</exception>
    /// <exception cref="ArgumentException">An argument is the default value; the number of arguments is not the arity; or a span is shorter than the rows of the result, in which case the message names the needed length.</exception>
    public MathBlockEvaluation EvaluateCoreCLR(in MathBlockSpanArgument a, in MathBlockSpanArgument b, in MathBlockSpanArgument c, Span<double> output, Span<bool> rowValid, MathBlockDomainOptions domainOptions)
    {
        RequireInitialized(in a, nameof(a));
        RequireInitialized(in b, nameof(b));
        RequireInitialized(in c, nameof(c));
        return EvaluateRowOperands(new MathBlockSpanOperands(in a, in b, in c), output, rowValid, domainOptions);
    }

    // The evaluation of inputs that are values: a kernel when one serves them, otherwise the allocating evaluation.
    internal MathBlockEvaluation EvaluateInto(ReadOnlySpan<MathBlockValue> inputs, Span<double> output, MathBlockDomainOptions domainOptions)
    {
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        if (SpanKernel is { } kernel)
        {
            var operands = MathBlockSpanOperands.FromValues(inputs);
            if (kernel(in operands, domainOptions, output, out var kernelRows, out var kernelValid))
                return new MathBlockEvaluation(kernelValid, kernelRows, 0);
        }

        return EvaluateValuesInto(inputs.ToArray(), output, domainOptions);
    }

    internal MathBlockEvaluation EvaluateRowsInto(ReadOnlySpan<MathBlockValue> inputs, Span<double> output, Span<bool> rowValid, MathBlockDomainOptions domainOptions)
    {
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        if (SpanRowKernel is { } kernel)
        {
            var operands = MathBlockSpanOperands.FromValues(inputs);
            if (kernel(in operands, output, rowValid, out var kernelRows))
                return new MathBlockEvaluation(true, kernelRows, 0);
        }

        return EvaluateFormInto(inputs.ToArray(), output, rowValid, domainOptions);
    }

    private MathBlockEvaluation EvaluateOperands(in MathBlockSpanOperands operands, Span<double> output, MathBlockDomainOptions domainOptions)
    {
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        if (SpanKernel is { } kernel && kernel(in operands, domainOptions, output, out var kernelRows, out var kernelValid))
            return new MathBlockEvaluation(kernelValid, kernelRows, 0);
        return EvaluateValuesInto(operands.ToValues(), output, domainOptions);
    }

    private MathBlockEvaluation EvaluateRowOperands(in MathBlockSpanOperands operands, Span<double> output, Span<bool> rowValid, MathBlockDomainOptions domainOptions)
    {
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        if (SpanRowKernel is { } kernel && kernel(in operands, output, rowValid, out var kernelRows))
            return new MathBlockEvaluation(true, kernelRows, 0);
        RequireElementwiseForm();
        return EvaluateFormInto(operands.ToValues(), output, rowValid, domainOptions);
    }

    private MathBlockEvaluation EvaluateValuesInto(MathBlockValue[] values, Span<double> output, MathBlockDomainOptions domainOptions)
    {
        var context = new MathBlockDomainContext(domainOptions);
        var result = Evaluate(values, context);
        return CopyResult(result, output, context.NonConverged);
    }

    private MathBlockEvaluation EvaluateFormInto(MathBlockValue[] values, Span<double> output, Span<bool> rowValid, MathBlockDomainOptions domainOptions)
    {
        RequireElementwiseForm();
        var context = new MathBlockDomainContext(domainOptions);
        var form = Evaluate(values, context);
        if (!form.IsValid)
            return new MathBlockEvaluation(false, form.Type.Rows, context.NonConverged);
        var validityOperation = MathBlockCatalog.Standard.Get("elementwise-valid." + Identifier[ElementwisePrefix.Length..], Version);
        var validity = validityOperation.Evaluate(values.AsSpan(0, values.Length - 1).ToArray(), new MathBlockDomainContext(domainOptions, counting: false));
        if (!validity.IsValid)
            return new MathBlockEvaluation(false, validity.Type.Rows, context.NonConverged);
        var vector = form.AsVector();
        var flags = validity.AsBooleanVector();
        RequireOutput(output, vector.Count);
        if (rowValid.Length < flags.Count)
        {
            throw new ArgumentException(
                string.Create(CultureInfo.InvariantCulture, $"The row validity span needs {flags.Count} elements; it has {rowValid.Length}."),
                nameof(rowValid));
        }

        vector.Span.CopyTo(output);
        for (var index = 0; index < flags.Count; index++)
            rowValid[index] = flags[index];
        return new MathBlockEvaluation(true, vector.Count, context.NonConverged);
    }

    private const string ElementwisePrefix = "elementwise.";

    // The identity text is built on every Identity read, so the span kernels are resolved once and kept. A race
    // resolves a kernel twice or reads none yet, which only sends a call to the allocating evaluation.
    private MathBlockSpanKernels.Kernel? SpanKernel => spanKernelResolved ? spanKernel : ResolveSpanKernel();

    private MathBlockSpanKernels.RowKernel? SpanRowKernel => spanRowKernelResolved ? spanRowKernel : ResolveSpanRowKernel();

    private MathBlockSpanKernels.Kernel? ResolveSpanKernel()
    {
        spanKernel = MathBlockSpanKernels.Find(Identity);
        spanKernelResolved = true;
        return spanKernel;
    }

    private MathBlockSpanKernels.RowKernel? ResolveSpanRowKernel()
    {
        spanRowKernel = MathBlockSpanKernels.FindRows(Identity);
        spanRowKernelResolved = true;
        return spanRowKernel;
    }

    private void RequireElementwiseForm()
    {
        if (!Identifier.StartsWith(ElementwisePrefix, StringComparison.Ordinal))
            throw new InvalidOperationException($"'{Identity}' is not an elementwise form.");
    }

    private static void RequireInitialized(in MathBlockSpanArgument argument, string name)
    {
        if (argument.Kind == 0)
            throw new ArgumentException("The span argument is the default value; create it with Scalar, Vector or BooleanVector.", name);
    }

    private static MathBlockEvaluation CopyResult(MathBlockValue result, Span<double> output, long nonConverged)
    {
        if (!result.IsValid)
            return new MathBlockEvaluation(false, result.Type.Rows, nonConverged);
        switch (result.Type.Kind)
        {
            case MathBlockValueKind.Vector:
                var vector = result.AsVector();
                RequireOutput(output, vector.Count);
                vector.Span.CopyTo(output);
                return new MathBlockEvaluation(true, vector.Count, nonConverged);
            case MathBlockValueKind.BooleanVector:
                var flags = result.AsBooleanVector();
                RequireOutput(output, flags.Count);
                for (var index = 0; index < flags.Count; index++)
                    output[index] = flags[index] ? 1d : 0d;
                return new MathBlockEvaluation(true, flags.Count, nonConverged);
            default:
                throw new InvalidOperationException("The operation does not return a vector or a Boolean vector.");
        }
    }

    private static void RequireOutput(Span<double> output, int rows)
    {
        if (output.Length < rows)
        {
            throw new ArgumentException(
                string.Create(CultureInfo.InvariantCulture, $"The output span needs {rows} elements; it has {output.Length}."),
                nameof(output));
        }
    }
}
