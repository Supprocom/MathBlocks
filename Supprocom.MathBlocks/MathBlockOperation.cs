namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Operation contract.</summary>
public sealed class MathBlockOperation
{
    private readonly MathBlockTypeResolver typeResolver;
    private readonly MathBlockEvaluator evaluator;
    private MathBlockDomainEvaluator? domainEvaluator;
    private readonly MathBlockCausalityInfo? causality;
    private readonly Lazy<MathBlockTypeSignature?> typeSignature;

    /// <summary>Creates a versioned operation with type and evaluation contracts.</summary>
    /// <remarks>
    /// An operation created by this constructor has no causality label, so reading <see cref="Causality"/> throws.
    /// </remarks>
    public MathBlockOperation(
        string identifier,
        int version,
        int arity,
        MathBlockTypeResolver typeResolver,
        MathBlockEvaluator evaluator,
        IEnumerable<MathBlockRegressionCase> regressionCases,
        MathBlockPerformanceCase performanceCase)
        : this(identifier, version, arity, typeResolver, evaluator, regressionCases, performanceCase, null, false)
    {
    }

    /// <summary>Creates a versioned operation with type and evaluation contracts and a causality label.</summary>
    public MathBlockOperation(
        string identifier,
        int version,
        int arity,
        MathBlockTypeResolver typeResolver,
        MathBlockEvaluator evaluator,
        IEnumerable<MathBlockRegressionCase> regressionCases,
        MathBlockPerformanceCase performanceCase,
        MathBlockCausalityInfo causality)
        : this(identifier, version, arity, typeResolver, evaluator, regressionCases, performanceCase, causality, true)
    {
    }

    private MathBlockOperation(
        string identifier,
        int version,
        int arity,
        MathBlockTypeResolver typeResolver,
        MathBlockEvaluator evaluator,
        IEnumerable<MathBlockRegressionCase> regressionCases,
        MathBlockPerformanceCase performanceCase,
        MathBlockCausalityInfo? causality,
        bool requireCausality)
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
        if (requireCausality)
        {
            ArgumentNullException.ThrowIfNull(causality);
            if (causality.WidthInputIndex is { } widthInputIndex && widthInputIndex >= arity)
                throw new ArgumentException("The width input index is outside the operation arity.", nameof(causality));
        }
        this.causality = causality;
        typeSignature = new Lazy<MathBlockTypeSignature?>(
            () => TypeSignatureFactory?.Invoke() ?? MathBlockTypeSignatureCatalog.Create(Identity),
            LazyThreadSafetyMode.ExecutionAndPublication);
    }

    /// <summary>Evaluates the operation with the given domain limits.</summary>
    public MathBlockValue Evaluate(IReadOnlyList<MathBlockValue> inputs, MathBlockDomainOptions domainOptions)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        return Evaluate(inputs, new MathBlockDomainContext(domainOptions));
    }

    // Evaluates under the context's options; the context counts the evaluations that do not converge. An operation with no
    // domain-dependent check evaluates as Evaluate(inputs) does.
    internal MathBlockValue Evaluate(IReadOnlyList<MathBlockValue> inputs, MathBlockDomainContext context) =>
        domainEvaluator is { } domain
            ? EvaluateWith(inputs, values => domain(values, context))
            : Evaluate(inputs);

    // The evaluator that reads domain options; set by MathBlockOperationFactory.CreateDomain, whose Evaluate(inputs) is this
    // evaluator under the default context.
    internal MathBlockDomainEvaluator? DomainEvaluator
    {
        get => domainEvaluator;
        set => domainEvaluator = value;
    }

    /// <summary>Gets the limits that apply to the operation, resolved with <see cref="Cuda.MathBlocksCudaOptions.Default"/>.</summary>
    public IReadOnlyList<MathBlockLimit> Limits => MathBlockLimitCatalog.For(Identity, Cuda.MathBlocksCudaOptions.Default, MathBlockDomainOptions.Default);

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
    /// <summary>Gets which input rows the operation's output reads.</summary>
    /// <exception cref="InvalidOperationException">The operation was created without a causality label.</exception>
    public MathBlockCausalityInfo Causality =>
        causality ?? throw new InvalidOperationException($"Operation '{Identity}' has no causality label.");

    /// <summary>Gets the data form of the output-type rule, or null when no signature covers the operation.</summary>
    /// <remarks>
    /// When the operation has a signature, <see cref="ResolveOutputType"/> resolves through it, with the same code the CUDA
    /// type-rule module runs.
    /// </remarks>
    public MathBlockTypeSignature? TypeSignature => typeSignature.Value;

    // Builds the signature of an operation that is a lift of another operation, where the signature follows from the
    // source's. Other operations take theirs from MathBlockTypeSignatureCatalog.
    internal Func<MathBlockTypeSignature?>? TypeSignatureFactory { get; set; }

    // The resolver delegate the operation was created with. It is the reference the signature is tested against, and it
    // supplies the exception of a rejected input and the type of an operation without a signature.
    internal MathBlockTypeResolver LegacyTypeResolver => typeResolver;

    // Refines the resolved output type from the inputs that are program constants (null for every other input), for
    // an operation whose output shape depends on an input value, such as a rolling window's width. The program
    // builder applies it, so a length that follows from constants is part of the node type at build time.
    internal Func<MathBlockType, IReadOnlyList<MathBlockType>, IReadOnlyList<MathBlockValue?>, MathBlockType>? ConstantRefinement { get; set; }

    // The raw scalar function of an operation built by MathBlockOperationFactory.ScalarUnary or ScalarBinary, which is
    // exactly the function that factory's evaluator applies to the scalar inputs. Every other operation has none.
    // The elementwise form reads it to run its rows without the per-row Evaluate overhead.
    internal Func<double, double>? UnaryKernel { get; set; }
    internal Func<double, double, double>? BinaryKernel { get; set; }

    /// <summary>Validates input types and resolves the operation output type.</summary>
    public MathBlockType ResolveOutputType(IReadOnlyList<MathBlockType> inputTypes)
    {
        ArgumentNullException.ThrowIfNull(inputTypes);
        RequireArity(inputTypes.Count);
        if (TypeSignature is not { } signature)
            return typeResolver(inputTypes);
        if (MathBlockTypeSignatures.ResolveListStatus(signature, inputTypes, out var resolved) == MathBlockTypeRuleStatus.Ok)
            return resolved;
        // The inputs are rejected: the delegate raises the exception callers have always received for them.
        _ = typeResolver(inputTypes);
        throw new InvalidOperationException($"The type signature of '{Identity}' rejects inputs that its resolver accepts.");
    }

    /// <summary>Evaluates the operation with positional input values.</summary>
    public MathBlockValue Evaluate(params MathBlockValue[] inputs) => Evaluate((IReadOnlyList<MathBlockValue>)inputs);

    /// <summary>Evaluates the operation with a read-only input list.</summary>
    public MathBlockValue Evaluate(IReadOnlyList<MathBlockValue> inputs) => EvaluateWith(inputs, evaluator);

    // Runs the public evaluation contract (arity, type resolution, invalid inputs, caught domain exceptions and the
    // declared-type check) around another evaluator for the same operation. The window batch uses it to share
    // width-independent work across widths while each result goes through the same checks as Evaluate.
    internal MathBlockValue EvaluateWith(IReadOnlyList<MathBlockValue> inputs, MathBlockEvaluator replacement)
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
            result = replacement(inputs);
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
        // An invalid result has exactly the declared type for these inputs, as on CUDA, so a value factory that
        // keeps a computed length (a nonfinite vector, for example) does not add shape the declared type lacks.
        return result.IsValid || result.Type == outputType ? result : MathBlockValue.Invalid(outputType, result.InvalidReason!);
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
