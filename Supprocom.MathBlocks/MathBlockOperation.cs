namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Operation contract.</summary>
public sealed class MathBlockOperation
{
    private readonly MathBlockTypeResolver typeResolver;
    private readonly MathBlockEvaluator evaluator;

    /// <summary>Creates a versioned operation with type and evaluation contracts.</summary>
    public MathBlockOperation(
        string identifier,
        int version,
        int arity,
        MathBlockTypeResolver typeResolver,
        MathBlockEvaluator evaluator,
        IEnumerable<MathBlockRegressionCase> regressionCases,
        MathBlockPerformanceCase performanceCase)
    {
        Identifier = RequireIdentifier(identifier);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(version);
        ArgumentOutOfRangeException.ThrowIfNegative(arity);
        ArgumentNullException.ThrowIfNull(typeResolver);
        ArgumentNullException.ThrowIfNull(evaluator);
        ArgumentNullException.ThrowIfNull(regressionCases);
        ArgumentNullException.ThrowIfNull(performanceCase);
        Version = version;
        Arity = arity;
        this.typeResolver = typeResolver;
        this.evaluator = evaluator;
        RegressionCases = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(regressionCases));
        if (RegressionCases.Count == 0)
            throw new ArgumentException("Each operation requires regression evidence.", nameof(regressionCases));
        PerformanceCase = performanceCase;
    }

    /// <summary>Gets the identifier value.</summary>
    public string Identifier { get; }
    /// <summary>Gets the version value.</summary>
    public int Version { get; }
    /// <summary>Gets the arity value.</summary>
    public int Arity { get; }
    /// <summary>Gets the identity value.</summary>
    public string Identity => $"{Identifier}@{Version}";
    /// <summary>Gets the regression cases value.</summary>
    public IReadOnlyList<MathBlockRegressionCase> RegressionCases { get; }
    /// <summary>Gets the performance case value.</summary>
    public MathBlockPerformanceCase PerformanceCase { get; }

    /// <summary>Validates input types and resolves the operation output type.</summary>
    public MathBlockType ResolveOutputType(IReadOnlyList<MathBlockType> inputTypes)
    {
        ArgumentNullException.ThrowIfNull(inputTypes);
        RequireArity(inputTypes.Count);
        return typeResolver(inputTypes);
    }

    /// <summary>Evaluates the operation with positional input values.</summary>
    public MathBlockValue Evaluate(params MathBlockValue[] inputs) => Evaluate((IReadOnlyList<MathBlockValue>)inputs);

    /// <summary>Evaluates the operation with a read-only input list.</summary>
    public MathBlockValue Evaluate(IReadOnlyList<MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        RequireArity(inputs.Count);
        var outputType = typeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        var invalidIndex = -1;
        for (var index = 0; index < inputs.Count; index++)
        {
            if (inputs[index].IsValid)
                continue;
            invalidIndex = index;
            break;
        }
        if (invalidIndex >= 0)
        {
            var invalidInput = inputs[invalidIndex];
            var reason = invalidInput.InvalidReason ?? "An input value is invalid.";
            return MathBlockValue.Invalid(outputType, reason);
        }

        MathBlockValue result;
        try
        {
            result = evaluator(inputs);
        }
        catch (ArithmeticException exception)
        {
            return MathBlockValue.Invalid(outputType, exception.Message);
        }
        catch (ArgumentOutOfRangeException exception)
        {
            return MathBlockValue.Invalid(outputType, exception.Message);
        }
        catch (IndexOutOfRangeException exception)
        {
            return MathBlockValue.Invalid(outputType, exception.Message);
        }
        if (!outputType.Accepts(result.Type))
        {
            throw new InvalidOperationException(
                $"Operation '{Identity}' returned '{result.Type}', but its declared type is '{outputType}'.");
        }
        return result;
    }

    private void RequireArity(int actual)
    {
        if (actual != Arity)
            throw new ArgumentException($"Operation '{Identity}' requires {Arity} inputs, but received {actual}.");
    }

    private static string RequireIdentifier(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("An operation identifier is required.", nameof(value));
        value = value.Trim();
        for (var index = 0; index < value.Length; index++)
        {
            var character = value[index];
            if (character is not (>= 'a' and <= 'z' or >= '0' and <= '9' or '.' or '-'))
                throw new ArgumentException("An operation identifier contains an unsupported character.", nameof(value));
        }
        return value;
    }
}
