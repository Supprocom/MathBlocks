namespace Supprocom.MathBlocks;

public sealed class MathBlocksCPUWorker
{
    private static readonly Lazy<MathBlocksCPUWorker> shared = new(
        () => new MathBlocksCPUWorker(),
        LazyThreadSafetyMode.ExecutionAndPublication);

    private readonly ParallelOptions parallelOptions;

    public MathBlocksCPUWorker(int maximumConcurrency = -1)
    {
        if (maximumConcurrency == 0 || maximumConcurrency < -1)
            throw new ArgumentOutOfRangeException(nameof(maximumConcurrency));

        MaximumConcurrency = maximumConcurrency;
        parallelOptions = new ParallelOptions { MaxDegreeOfParallelism = maximumConcurrency };
    }

    public static MathBlocksCPUWorker Shared => shared.Value;
    public int MaximumConcurrency { get; }

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
                ExecuteNode(program.Nodes[level[0]], values, level[0]);
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
