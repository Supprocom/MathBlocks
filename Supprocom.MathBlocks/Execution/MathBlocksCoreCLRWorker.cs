namespace Supprocom.MathBlocks;

/// <summary>Executes MathBlocks programs on CoreCLR.</summary>
public sealed class MathBlocksCoreCLRWorker
{
    private static readonly Lazy<MathBlocksCoreCLRWorker> shared = new(
        () => new MathBlocksCoreCLRWorker(),
        LazyThreadSafetyMode.ExecutionAndPublication);

    private readonly ParallelOptions parallelOptions;

    /// <summary>Creates a CoreCLR executor with an optional concurrency limit.</summary>
    public MathBlocksCoreCLRWorker(int maximumConcurrency = -1)
    {
        if (maximumConcurrency == 0 || maximumConcurrency < -1)
            throw new ArgumentOutOfRangeException(nameof(maximumConcurrency));

        MaximumConcurrency = maximumConcurrency;
        parallelOptions = new ParallelOptions { MaxDegreeOfParallelism = maximumConcurrency };
    }

    /// <summary>Gets the shared value.</summary>
    public static MathBlocksCoreCLRWorker Shared => shared.Value;
    /// <summary>Gets the maximum concurrency value.</summary>
    public int MaximumConcurrency { get; }

    /// <summary>Executes a program over named inputs on CoreCLR.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Execute(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(inputs);

        var values = program.CreateValueBuffer(inputs);
        foreach (var level in program.OperationLevels)
        {
            if (level.Length == 1 || MaximumConcurrency == 1)
            {
                foreach (var nodeIndex in level)
                    ExecuteNode(program.Nodes[nodeIndex], values, nodeIndex);
                continue;
            }

            Parallel.For(
                0,
                level.Length,
                parallelOptions,
                levelIndex =>
                {
                    var nodeIndex = level[levelIndex];
                    ExecuteNode(program.Nodes[nodeIndex], values, nodeIndex);
                });
        }

        return program.CreateOutputs(values);
    }

    private static void ExecuteNode(
        MathBlockProgram.Node node,
        MathBlockValue[] values,
        int nodeIndex)
    {
        var arguments = new MathBlockValue[node.Inputs.Length];
        for (var inputIndex = 0; inputIndex < arguments.Length; inputIndex++)
            arguments[inputIndex] = values[node.Inputs[inputIndex]];
        values[nodeIndex] = node.Operation!.Evaluate(arguments);
    }
}
