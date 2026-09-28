namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Rolling Order Statistic Work Plan contract.</summary>
/// <param name="InputCount">The input count value.</param>
/// <param name="WindowWidth">The window width value.</param>
/// <param name="OutputCount">The output count value.</param>
/// <param name="Probability">The probability value.</param>
/// <param name="UsesLinearExtremeDeque">The uses linear extreme deque value.</param>
/// <param name="UsesParallelRadixPreparation">The uses parallel radix preparation value.</param>
/// <param name="RadixPassCount">The radix pass count value.</param>
/// <param name="ParallelKeyVisitCount">The parallel key visit count value.</param>
/// <param name="HeapOperationBound">The heap operation bound value.</param>
/// <param name="SelectionOperationBound">The selection operation bound value.</param>
/// <param name="TotalOperationBound">The total operation bound value.</param>
public readonly record struct MathBlockRollingOrderStatisticWorkPlan(
    int InputCount,
    int WindowWidth,
    int OutputCount,
    double Probability,
    bool UsesLinearExtremeDeque,
    bool UsesParallelRadixPreparation,
    int RadixPassCount,
    long ParallelKeyVisitCount,
    long HeapOperationBound,
    long SelectionOperationBound,
    long TotalOperationBound);
