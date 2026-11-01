using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

/// <summary>
/// Evaluates trailing-window forms over many widths, or with their validity rows, in one CoreCLR pass or one CUDA
/// graph launch.
/// </summary>
/// <remarks>
/// <para>The supported forms are <c>window.vector.minimum@1</c>, <c>window.vector.maximum@1</c>,
/// <c>window.vector.arg-minimum@1</c>, <c>window.vector.arg-maximum@1</c>, <c>window.vector.median@1</c> and
/// <c>window.vector.quantile@1</c>, which give the bits of their source on each window, and the six
/// <c>window-accurate.*</c> forms: <c>window-accurate.sum@1</c> and <c>window-accurate.mean@1</c>, the exact window
/// sum and mean correctly rounded, and <c>window-accurate.population-variance@1</c>,
/// <c>window-accurate.sample-variance@1</c>, <c>window-accurate.population-standard-deviation@1</c> and
/// <c>window-accurate.sample-standard-deviation@1</c>, within the stated bound of the exact window variance and
/// deviation.</para>
/// <para>Every result is bit-identical, including its type and invalid state, to evaluating the form's operation
/// alone with the same inputs. Work that depends only on the series is done once per call.</para>
/// </remarks>
public static class MathBlocksWindowBatch
{
    /// <summary>Evaluates a window form without scalar parameters at each width, on CoreCLR.</summary>
    /// <param name="series">The series input of the form.</param>
    /// <param name="formIdentity">The form identity, for example <c>window-accurate.sum@1</c>.</param>
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
    /// <param name="formIdentity">The form identity, for example <c>window-accurate.mean@1</c>.</param>
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

    /// <summary>Evaluates a window form without scalar parameters at each width, on CUDA, in one graph launch.</summary>
    /// <param name="worker">The CUDA worker that compiles and runs the program.</param>
    /// <param name="series">The series input of the form.</param>
    /// <param name="formIdentity">The form identity, for example <c>window-accurate.sum@1</c>.</param>
    /// <param name="widths">The widths, each evaluated as the form's width input.</param>
    /// <param name="fill">The fill value, in the unit of the form's result.</param>
    /// <returns>One vector per width, in the order of <paramref name="widths"/>.</returns>
    /// <exception cref="ArgumentException">
    /// The batch doesn't support <paramref name="formIdentity"/>, or the form takes scalar parameters.
    /// </exception>
    /// <exception cref="InvalidOperationException">A width is outside 1 .. the series length.</exception>
    public static IReadOnlyList<MathBlockValue> EvaluateCUDA(
        MathBlocksCUDAWorker worker,
        MathBlockValue series,
        string formIdentity,
        IReadOnlyList<int> widths,
        double fill) =>
        EvaluateCUDA(worker, series, formIdentity, [], widths, fill);

    /// <summary>Evaluates a window form at each width, on CUDA, in one graph launch.</summary>
    /// <param name="worker">The CUDA worker that compiles and runs the program.</param>
    /// <param name="series">The series input of the form.</param>
    /// <param name="formIdentity">The form identity, for example <c>window.vector.quantile@1</c>.</param>
    /// <param name="parameters">The form's scalar parameters in input order, between the series and the width.</param>
    /// <param name="widths">The widths, each evaluated as the form's width input.</param>
    /// <param name="fill">The fill value, in the unit of the form's result.</param>
    /// <returns>
    /// One vector per width, in the order of <paramref name="widths"/>. The program holds one node of the form per
    /// width on the shared series, parameters and fill, each planned with its width as a constant, so each result is
    /// bit-identical to evaluating the form alone on CUDA with that width, and to the CoreCLR result.
    /// </returns>
    /// <exception cref="ArgumentException">
    /// The batch doesn't support <paramref name="formIdentity"/>, or the parameter count doesn't match the form.
    /// </exception>
    /// <exception cref="InvalidOperationException">A width is outside 1 .. the series length.</exception>
    public static IReadOnlyList<MathBlockValue> EvaluateCUDA(
        MathBlocksCUDAWorker worker,
        MathBlockValue series,
        string formIdentity,
        IReadOnlyList<MathBlockValue> parameters,
        IReadOnlyList<int> widths,
        double fill)
    {
        ArgumentNullException.ThrowIfNull(worker);
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
        if (widths.Count == 0)
            return [];

        var sourceTypes = new MathBlockType[entry.Form.SourceArity];
        sourceTypes[0] = series.Type;
        for (var index = 0; index < parameterCount; index++)
            sourceTypes[index + 1] = parameters[index].Type;
        var fillValue = MathBlockValue.Scalar(fill, entry.Form.ResolveResultUnit(sourceTypes));
        var operation = entry.FormOperation;
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal) { ["series"] = series, ["fill"] = fillValue };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = new int[operation.Arity];
        nodes[0] = builder.Input("series", series.Type);
        for (var index = 0; index < parameterCount; index++)
        {
            var name = $"parameter-{index}";
            inputs[name] = parameters[index];
            nodes[index + 1] = builder.Input(name, parameters[index].Type);
        }
        nodes[^1] = builder.Input("fill", fillValue.Type);
        for (var widthIndex = 0; widthIndex < widths.Count; widthIndex++)
        {
            nodes[^2] = builder.Constant(MathBlockValue.Scalar(widths[widthIndex]));
            builder.Output($"width-{widthIndex}", builder.Apply(operation.Identifier, operation.Version, nodes));
        }
        using var compiled = worker.Compile(builder.Build(), inputs);
        var outputs = compiled.Execute(inputs);
        var results = new MathBlockValue[widths.Count];
        for (var widthIndex = 0; widthIndex < widths.Count; widthIndex++)
            results[widthIndex] = outputs[$"width-{widthIndex}"];
        return results;
    }

    /// <summary>Evaluates a window form and its validity sibling on CUDA, in one graph launch.</summary>
    /// <param name="worker">The CUDA worker that compiles and runs the program.</param>
    /// <param name="formIdentity">The form identity, for example <c>window-accurate.mean@1</c>.</param>
    /// <param name="inputs">The form's inputs, ending with the width and the fill.</param>
    /// <returns>
    /// The form's result and the sibling's result for the same inputs without the fill, from one program with both
    /// nodes planned on these inputs. Each is bit-identical to evaluating that operation alone on CUDA, and to the
    /// CoreCLR result.
    /// </returns>
    /// <exception cref="ArgumentException">
    /// The batch doesn't support <paramref name="formIdentity"/>, or the input count doesn't match the form.
    /// </exception>
    /// <exception cref="InvalidOperationException">The width is outside 1 .. the series length.</exception>
    public static MathBlockWindowBatchResult EvaluateWithValidityCUDA(
        MathBlocksCUDAWorker worker,
        string formIdentity,
        IReadOnlyList<MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(worker);
        ArgumentNullException.ThrowIfNull(formIdentity);
        ArgumentNullException.ThrowIfNull(inputs);
        var entry = Resolve(formIdentity);
        if (inputs.Count != entry.FormOperation.Arity)
        {
            throw new ArgumentException(
                $"Window form '{formIdentity}' takes {entry.FormOperation.Arity} inputs, but received {inputs.Count}.",
                nameof(inputs));
        }
        var named = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = new int[inputs.Count];
        for (var index = 0; index < inputs.Count; index++)
        {
            var name = $"input-{index}";
            named[name] = inputs[index];
            nodes[index] = builder.Input(name, inputs[index].Type);
        }
        var form = entry.FormOperation;
        var validity = entry.ValidityOperation;
        builder.Output("values", builder.Apply(form.Identifier, form.Version, nodes));
        builder.Output("validity", builder.Apply(validity.Identifier, validity.Version, nodes[..^1]));
        using var compiled = worker.Compile(builder.Build(), named);
        var outputs = compiled.Execute(named);
        return new MathBlockWindowBatchResult(outputs["values"], outputs["validity"]);
    }

    private static MathBlockWindowEntry Resolve(string formIdentity) =>
        WindowMathBlocks.TryGetBatchEntry(formIdentity, out var entry)
            ? entry
            : throw new ArgumentException(
                $"Window form '{formIdentity}' is not supported by the window batch.",
                nameof(formIdentity));
}
