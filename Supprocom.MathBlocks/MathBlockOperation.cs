namespace Supprocom.MathBlocks;

public sealed class MathBlockRegressionCase
{
    public MathBlockRegressionCase(
        string name,
        IEnumerable<MathBlockValue> inputs,
        MathBlockValue expected,
        double tolerance = 1e-10)
    {
        Name = RequireText(name, nameof(name));
        ArgumentNullException.ThrowIfNull(inputs);
        Inputs = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(inputs));
        Expected = expected;
        if (!Math.IsFinite(tolerance) || tolerance < 0d)
            throw new ArgumentOutOfRangeException(nameof(tolerance));
        Tolerance = tolerance;
    }

    public string Name { get; }
    public IReadOnlyList<MathBlockValue> Inputs { get; }
    public MathBlockValue Expected { get; }
    public double Tolerance { get; }

    private static string RequireText(string value, string parameterName) =>
        string.IsNullOrWhiteSpace(value)
            ? throw new ArgumentException("A nonempty value is required.", parameterName)
            : value.Trim();
}

public sealed class MathBlockPerformanceCase
{
    public MathBlockPerformanceCase(
        IEnumerable<MathBlockValue> inputs,
        int iterations = 64,
        double maximumWarmLatencyMicroseconds = 1_000d)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        Inputs = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(inputs));
        if (iterations <= 0)
            throw new ArgumentOutOfRangeException(nameof(iterations));
        if (!Math.IsFinite(maximumWarmLatencyMicroseconds) ||
            maximumWarmLatencyMicroseconds <= 0d ||
            maximumWarmLatencyMicroseconds > 1_000d)
        {
            throw new ArgumentOutOfRangeException(nameof(maximumWarmLatencyMicroseconds));
        }
        Iterations = iterations;
        MaximumWarmLatencyMicroseconds = maximumWarmLatencyMicroseconds;
    }

    public IReadOnlyList<MathBlockValue> Inputs { get; }
    public int Iterations { get; }
    public double MaximumWarmLatencyMicroseconds { get; }
}

public delegate MathBlockType MathBlockTypeResolver(IReadOnlyList<MathBlockType> inputTypes);
public delegate MathBlockValue MathBlockEvaluator(IReadOnlyList<MathBlockValue> inputs);

public sealed class MathBlockOperation
{
    private readonly MathBlockTypeResolver typeResolver;
    private readonly MathBlockEvaluator evaluator;

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
        if (version <= 0)
            throw new ArgumentOutOfRangeException(nameof(version));
        if (arity < 0)
            throw new ArgumentOutOfRangeException(nameof(arity));
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

    public string Identifier { get; }
    public int Version { get; }
    public int Arity { get; }
    public string Identity => $"{Identifier}@{Version}";
    public IReadOnlyList<MathBlockRegressionCase> RegressionCases { get; }
    public MathBlockPerformanceCase PerformanceCase { get; }

    public MathBlockType ResolveOutputType(IReadOnlyList<MathBlockType> inputTypes)
    {
        ArgumentNullException.ThrowIfNull(inputTypes);
        RequireArity(inputTypes.Count);
        return typeResolver(inputTypes);
    }

    public MathBlockValue Evaluate(params MathBlockValue[] inputs) => Evaluate((IReadOnlyList<MathBlockValue>)inputs);

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
            if (!(character is >= 'a' and <= 'z' || character is >= '0' and <= '9' || character is '.' or '-'))
                throw new ArgumentException("An operation identifier contains an unsupported character.", nameof(value));
        }
        return value;
    }
}

public sealed class MathBlockRegistry
{
    private readonly Dictionary<string, MathBlockOperation> operations;

    public MathBlockRegistry(IEnumerable<MathBlockOperation> operations)
    {
        ArgumentNullException.ThrowIfNull(operations);
        this.operations = new Dictionary<string, MathBlockOperation>(StringComparer.Ordinal);
        foreach (var operation in operations)
        {
            ArgumentNullException.ThrowIfNull(operation);
            if (!this.operations.TryAdd(operation.Identity, operation))
                throw new ArgumentException($"Duplicate MathBlock operation '{operation.Identity}'.", nameof(operations));
        }
        if (this.operations.Count == 0)
            throw new ArgumentException("The registry must contain an operation.", nameof(operations));
        var ordered = MathBlockCollectionPrimitives.CopyEnumerable(this.operations.Values);
        MathBlockCollectionPrimitives.StableMergeSort(
            ordered,
            (left, right) => StringComparer.Ordinal.Compare(left.Identity, right.Identity));
        Operations = Array.AsReadOnly(ordered);
    }

    public IReadOnlyList<MathBlockOperation> Operations { get; }

    public MathBlockOperation Get(string identifier, int version = 1)
    {
        var identity = $"{identifier}@{version}";
        return operations.TryGetValue(identity, out var operation)
            ? operation
            : throw new KeyNotFoundException($"MathBlock operation '{identity}' is not registered.");
    }
}

internal static class MathBlockTypeRules
{
    public static MathBlockType SameBinaryScalar(IReadOnlyList<MathBlockType> types) =>
        SameBinary(types, MathBlockValueKind.Scalar);

    public static MathBlockType DimensionlessScalar(IReadOnlyList<MathBlockType> types) =>
        DimensionlessUnary(types, MathBlockValueKind.Scalar);

    public static MathBlockType DimensionlessScalarFromScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar();
    }

    public static MathBlockType DimensionlessBinaryScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        RequireKind(types[1], MathBlockValueKind.Scalar);
        RequireDimensionless(types[0]);
        RequireDimensionless(types[1]);
        return MathBlockType.Scalar();
    }

    public static MathBlockType ReciprocalScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(-1)));
    }

    public static MathBlockType SquareScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(2)));
    }

    public static MathBlockType CubeScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(3)));
    }

    public static MathBlockType SquareRootScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(1, 2)));
    }

    public static MathBlockType CubeRootScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(1, 3)));
    }

    public static MathBlockType Unary(IReadOnlyList<MathBlockType> types, MathBlockValueKind kind)
    {
        RequireKind(types[0], kind);
        return types[0];
    }

    public static MathBlockType DimensionlessUnary(IReadOnlyList<MathBlockType> types, MathBlockValueKind kind)
    {
        RequireKind(types[0], kind);
        RequireDimensionless(types[0]);
        return types[0];
    }

    public static MathBlockType SameBinary(IReadOnlyList<MathBlockType> types, MathBlockValueKind kind)
    {
        RequireKind(types[0], kind);
        RequireKind(types[1], kind);
        if (types[0].Unit != types[1].Unit)
            throw new InvalidOperationException("The input units must be equal.");
        RequireCompatibleShape(types[0], types[1]);
        return MergeShape(types[0], types[1]);
    }

    public static MathBlockType ScalarProduct(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        RequireKind(types[1], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Multiply(types[1].Unit));
    }

    public static MathBlockType ScalarQuotient(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        RequireKind(types[1], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Divide(types[1].Unit));
    }

    public static MathBlockType Comparison(IReadOnlyList<MathBlockType> types)
    {
        SameBinary(types, MathBlockValueKind.Scalar);
        return MathBlockType.Boolean;
    }

    public static MathBlockType VectorReduction(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar(types[0].Unit);
    }

    public static MathBlockType VectorDimensionlessReduction(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Vector);
        RequireDimensionless(types[0]);
        return MathBlockType.Scalar();
    }

    public static void RequireKind(MathBlockType type, MathBlockValueKind kind)
    {
        if (type.Kind != kind)
            throw new InvalidOperationException($"Expected '{kind}', but found '{type.Kind}'.");
    }

    public static void RequireDimensionless(MathBlockType type)
    {
        if (!type.Unit.IsDimensionless)
            throw new InvalidOperationException("The input must be dimensionless.");
    }

    public static void RequireCompatibleShape(MathBlockType left, MathBlockType right)
    {
        if (left.Rows != 0 && right.Rows != 0 && left.Rows != right.Rows)
            throw new InvalidOperationException("The input row counts must be equal.");
        if (left.Columns != 0 && right.Columns != 0 && left.Columns != right.Columns)
            throw new InvalidOperationException("The input column counts must be equal.");
    }

    private static MathBlockType MergeShape(MathBlockType left, MathBlockType right) =>
        new(left.Kind, left.Unit, left.Rows == 0 ? right.Rows : left.Rows, left.Columns == 0 ? right.Columns : left.Columns);
}
