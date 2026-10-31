namespace Supprocom.MathBlocks;

/// <summary>Evaluates trailing-window forms over many widths, or with their validity rows, in one CoreCLR pass.</summary>
/// <remarks>
/// The supported forms are the <c>window-prefix.*</c> forms and <c>window.vector.minimum@1</c>,
/// <c>window.vector.maximum@1</c>, <c>window.vector.arg-minimum@1</c>, <c>window.vector.arg-maximum@1</c>,
/// <c>window.vector.median@1</c> and <c>window.vector.quantile@1</c>. Every result is bit-identical, including its
/// type and invalid state, to evaluating the form's operation alone with the same inputs. Work that depends only on
/// the series is done once per call.
/// </remarks>
public static class MathBlocksWindowBatch
{
    /// <summary>Evaluates a window form without scalar parameters at each width, on CoreCLR.</summary>
    /// <param name="series">The series input of the form.</param>
    /// <param name="formIdentity">The form identity, for example <c>window-prefix.sum@1</c>.</param>
    /// <param name="widths">The widths, each evaluated as the form's width input.</param>
    /// <param name="fill">The fill value, in the unit of the form's result.</param>
    /// <returns>One vector per width, in the order of <paramref name="widths"/>.</returns>
    /// <exception cref="ArgumentException">
    /// The batch doesn't support <paramref name="formIdentity"/>, or the form takes scalar parameters.
    /// </exception>
    public static IReadOnlyList<MathBlockValue> Evaluate(
        MathBlockValue series,
        string formIdentity,
        IReadOnlyList<int> widths,
        double fill) =>
        Evaluate(series, formIdentity, [], widths, fill);

    /// <summary>Evaluates a window form at each width, on CoreCLR.</summary>
    /// <param name="series">The series input of the form.</param>
    /// <param name="formIdentity">The form identity, for example <c>window.vector.quantile@1</c>.</param>
    /// <param name="parameters">
    /// The form's scalar parameters in input order, between the series and the width; for example the probability of
    /// <c>window.vector.quantile@1</c>.
    /// </param>
    /// <param name="widths">The widths, each evaluated as the form's width input.</param>
    /// <param name="fill">The fill value, in the unit of the form's result.</param>
    /// <returns>
    /// One vector per width, in the order of <paramref name="widths"/>. Each is bit-identical to evaluating the form
    /// alone with the series, the parameters, that width and the fill.
    /// </returns>
    /// <exception cref="ArgumentException">
    /// The batch doesn't support <paramref name="formIdentity"/>, or the parameter count doesn't match the form.
    /// </exception>
    public static IReadOnlyList<MathBlockValue> Evaluate(
        MathBlockValue series,
        string formIdentity,
        IReadOnlyList<MathBlockValue> parameters,
        IReadOnlyList<int> widths,
        double fill)
    {
        ArgumentNullException.ThrowIfNull(formIdentity);
        ArgumentNullException.ThrowIfNull(parameters);
        ArgumentNullException.ThrowIfNull(widths);
        var entry = Resolve(formIdentity);
        var parameterCount = entry.Form.SourceArity - 1;
        if (parameters.Count != parameterCount)
        {
            throw new ArgumentException(
                $"Window form '{formIdentity}' takes {parameterCount} scalar parameters, but received {parameters.Count}.",
                nameof(parameters));
        }

        var sourceTypes = new MathBlockType[entry.Form.SourceArity];
        sourceTypes[0] = series.Type;
        for (var index = 0; index < parameterCount; index++)
            sourceTypes[index + 1] = parameters[index].Type;
        var fillValue = MathBlockValue.Scalar(fill, entry.Form.ResolveResultUnit(sourceTypes));
        var preparation = new MathBlockWindowPreparation();
        var form = entry.Form;
        var results = new MathBlockValue[widths.Count];
        for (var widthIndex = 0; widthIndex < widths.Count; widthIndex++)
        {
            var inputs = new MathBlockValue[entry.FormOperation.Arity];
            inputs[0] = series;
            for (var index = 0; index < parameterCount; index++)
                inputs[index + 1] = parameters[index];
            inputs[^2] = MathBlockValue.Scalar(widths[widthIndex]);
            inputs[^1] = fillValue;
            results[widthIndex] = entry.FormOperation.EvaluateWith(
                inputs,
                formInputs => form.EvaluateForm(formInputs, preparation, null));
        }
        return results;
    }

    /// <summary>Evaluates a window form and its validity sibling from one CoreCLR pass.</summary>
    /// <param name="formIdentity">The form identity, for example <c>window-prefix.mean@1</c>.</param>
    /// <param name="inputs">The form's inputs, ending with the width and the fill.</param>
    /// <returns>
    /// The form's result and the sibling's result for the same inputs without the fill. Each is bit-identical to
    /// evaluating that operation alone.
    /// </returns>
    /// <exception cref="ArgumentException">The batch doesn't support <paramref name="formIdentity"/>.</exception>
    public static MathBlockWindowBatchResult EvaluateWithValidity(
        string formIdentity,
        IReadOnlyList<MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(formIdentity);
        ArgumentNullException.ThrowIfNull(inputs);
        var entry = Resolve(formIdentity);
        var form = entry.Form;
        var capture = new MathBlockWindowValidityCapture();
        var values = entry.FormOperation.EvaluateWith(inputs, formInputs => form.EvaluateForm(formInputs, null, capture));
        var validityInputs = new MathBlockValue[Math.Max(inputs.Count - 1, 0)];
        for (var index = 0; index < validityInputs.Length; index++)
            validityInputs[index] = inputs[index];
        // The capture holds rows only when the form reached its row pass. The sibling's checks are a subset of the
        // form's, so it would compute those same rows; otherwise it runs on its own.
        var validity = entry.ValidityOperation.EvaluateWith(
            validityInputs,
            siblingInputs => capture.Valid is { } valid
                ? MathBlockValue.BooleanVector(valid, true)
                : form.EvaluateValidity(siblingInputs, null));
        return new MathBlockWindowBatchResult(values, validity);
    }

    private static MathBlockWindowEntry Resolve(string formIdentity) =>
        WindowMathBlocks.TryGetBatchEntry(formIdentity, out var entry)
            ? entry
            : throw new ArgumentException(
                $"Window form '{formIdentity}' is not supported by the window batch.",
                nameof(formIdentity));
}
