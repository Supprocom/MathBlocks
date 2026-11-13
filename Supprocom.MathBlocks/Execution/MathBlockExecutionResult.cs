namespace Supprocom.MathBlocks;

/// <summary>Holds the outputs of one program execution and the evaluations that ended at an iteration budget without converging.</summary>
public sealed class MathBlockExecutionResult
{
    internal MathBlockExecutionResult(
        IReadOnlyDictionary<string, MathBlockValue> outputs,
        IReadOnlyDictionary<string, long> nonConvergedEvaluations)
    {
        Outputs = outputs;
        NonConvergedEvaluations = nonConvergedEvaluations;
    }

    /// <summary>Gets the named output values.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Outputs { get; }

    /// <summary>Gets, by operation identity, how many evaluations ended without converging; empty when there are none.</summary>
    /// <remarks>
    /// An evaluation counts when the incomplete-beta continued fraction used every iteration of
    /// <see cref="MathBlockDomainOptions.IncompleteBetaMaximumIterations"/> without reaching the tolerance, or the Jacobi eigenvalue
    /// iteration used its rotation budget with an off-diagonal entry left. It counts under both
    /// <see cref="MathBlockNonConvergencePolicy"/> values, on CoreCLR and on CUDA. An elementwise form counts each row.
    /// </remarks>
    public IReadOnlyDictionary<string, long> NonConvergedEvaluations { get; }
}
