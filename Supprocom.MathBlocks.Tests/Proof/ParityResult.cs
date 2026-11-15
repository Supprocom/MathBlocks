namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>The rows that the parity kernel wrote for one operation: the row function, and the elementwise row function in the legacy and in the wide opcode encoding.</summary>
/// <param name="RowBits">The bits of the row function's values.</param>
/// <param name="RowValid">The row function's validity, 1 or 0.</param>
/// <param name="NarrowBits">The bits of the elementwise row's values, legacy opcode.</param>
/// <param name="NarrowValid">The elementwise row's validity, legacy opcode.</param>
/// <param name="WideBits">The bits of the elementwise row's values, wide opcode.</param>
/// <param name="WideValid">The elementwise row's validity, wide opcode.</param>
internal sealed record ParityResult(long[] RowBits, int[] RowValid, long[] NarrowBits, int[] NarrowValid, long[] WideBits, int[] WideValid);
