namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>One parameter setting of a sequence operation: k for lead and lag, or start and end for the offset operations.</summary>
/// <param name="Label">The label of the setting in the report.</param>
/// <param name="First">The first scalar: k, or start.</param>
/// <param name="Second">The second scalar: end; equal to k for lead and lag, which do not read it.</param>
/// <param name="Width">The size of the parameter: k, or the number of offsets end - start + 1.</param>
internal sealed record ProofParameter(string Label, float First, float Second, float Width);
