namespace Supprocom.MathBlocks;

/// <summary>Describes the outcome of one non-allocating CoreCLR evaluation that wrote its rows into a caller-owned span.</summary>
/// <param name="IsValid">Whether the result is valid; when false the span contents are unspecified.</param>
/// <param name="Rows">The number of rows of the result.</param>
/// <param name="NonConvergedCount">The number of rows whose iteration stopped at its budget without converging.</param>
public readonly record struct MathBlockEvaluation(bool IsValid, int Rows, long NonConvergedCount);
