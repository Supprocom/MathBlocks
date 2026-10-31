namespace Supprocom.MathBlocks;

// Receives the validity rows that a form evaluation computed in the same pass as its values.
internal sealed class MathBlockWindowValidityCapture
{
    internal bool[]? Valid { get; set; }
}
