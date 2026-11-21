namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>One measurement of the vector-block table: a call on one input class at one row count, in nanoseconds per row.</summary>
/// <param name="Call">The call.</param>
/// <param name="ClassName">The input class name.</param>
/// <param name="Rows">The row count.</param>
/// <param name="NanosecondsPerRow">The median time per row of seven launches, measured with CUDA events.</param>
internal sealed record VectorBlockCell(VectorBlockCall Call, string ClassName, int Rows, float NanosecondsPerRow);
