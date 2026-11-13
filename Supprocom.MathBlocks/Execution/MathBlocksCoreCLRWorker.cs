namespace Supprocom.MathBlocks;

/// <summary>Executes MathBlocks programs on CoreCLR.</summary>
public sealed class MathBlocksCoreCLRWorker
{
    private static readonly Lazy<MathBlocksCoreCLRWorker> shared = new(
        () => new MathBlocksCoreCLRWorker(),
        LazyThreadSafetyMode.ExecutionAndPublication);

    private readonly ParallelOptions parallelOptions;
    private readonly MathBlockDomainOptions domainOptions;

    /// <summary>Creates a CoreCLR executor with an optional concurrency limit.</summary>
    public MathBlocksCoreCLRWorker(int maximumConcurrency = -1)
        : this(MathBlockDomainOptions.Default, maximumConcurrency)
    {
    }

    private MathBlocksCoreCLRWorker(MathBlockDomainOptions domainOptions, int maximumConcurrency)
    {
        if (maximumConcurrency == 0 || maximumConcurrency < -1)
            throw new ArgumentOutOfRangeException(nameof(maximumConcurrency));

        this.domainOptions = domainOptions;
        MaximumConcurrency = maximumConcurrency;
        parallelOptions = new ParallelOptions { MaxDegreeOfParallelism = maximumConcurrency };
    }

    /// <summary>Creates a CoreCLR executor that applies the given domain limits and an optional concurrency limit.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A domain option is outside the range its limit allows.</exception>
    public static MathBlocksCoreCLRWorker Create(MathBlockDomainOptions domainOptions, int maximumConcurrency = -1)
    {
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        return new MathBlocksCoreCLRWorker(domainOptions, maximumConcurrency);
    }

    /// <summary>Gets the shared value.</summary>
    public static MathBlocksCoreCLRWorker Shared => shared.Value;
    /// <summary>Gets the domain limits applied to the program's operations.</summary>
    public MathBlockDomainOptions DomainOptions => domainOptions;
    /// <summary>Gets the maximum concurrency value.</summary>
    public int MaximumConcurrency { get; }

    /// <summary>Executes a program over named inputs on CoreCLR.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Execute(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue> inputs) => ExecuteWithDiagnostics(program, inputs).Outputs;

    /// <summary>Executes a program over named inputs on CoreCLR and reports the evaluations that ended without converging.</summary>
    public MathBlockExecutionResult ExecuteWithDiagnostics(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(inputs);

        var values = program.CreateValueBuffer(inputs);
        var nonConverged = new long[program.Nodes.Length];
        foreach (var level in program.OperationLevels)
        {
            if (level.Length == 1 || MaximumConcurrency == 1)
            {
                foreach (var nodeIndex in level)
                    ExecuteNode(program.Nodes[nodeIndex], values, nodeIndex, nonConverged);
                continue;
            }

            Parallel.For(
                0,
                level.Length,
                parallelOptions,
                levelIndex =>
                {
                    var nodeIndex = level[levelIndex];
                    ExecuteNode(program.Nodes[nodeIndex], values, nodeIndex, nonConverged);
                });
        }

        var counts = new Dictionary<string, long>(StringComparer.Ordinal);
        for (var nodeIndex = 0; nodeIndex < nonConverged.Length; nodeIndex++)
        {
            if (nonConverged[nodeIndex] != 0)
            {
                var identity = program.Nodes[nodeIndex].Operation!.Identity;
                counts[identity] = counts.GetValueOrDefault(identity) + nonConverged[nodeIndex];
            }
        }

        return new MathBlockExecutionResult(program.CreateOutputs(values), counts);
    }

    private void ExecuteNode(
        MathBlockProgram.Node node,
        MathBlockValue[] values,
        int nodeIndex,
        long[] nonConverged)
    {
        var arguments = new MathBlockValue[node.Inputs.Length];
        for (var inputIndex = 0; inputIndex < arguments.Length; inputIndex++)
            arguments[inputIndex] = values[node.Inputs[inputIndex]];
        var context = new MathBlockDomainContext(domainOptions);
        values[nodeIndex] = node.Operation!.Evaluate(arguments, context);
        nonConverged[nodeIndex] = context.NonConverged;
    }
}
