namespace Supprocom.MathBlocks;

// A window form with its two registered operations: the form and its validity sibling.
internal sealed record MathBlockWindowEntry(
    MathBlockWindowForm Form,
    MathBlockOperation FormOperation,
    MathBlockOperation ValidityOperation);
