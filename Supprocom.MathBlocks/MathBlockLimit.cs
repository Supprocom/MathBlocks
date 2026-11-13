namespace Supprocom.MathBlocks;

/// <summary>Describes one limit of the library or of one operation in a machine-readable form.</summary>
/// <param name="Name">The stable limit name, such as <c>cuda.grid-x</c>.</param>
/// <param name="Operation">The operation or form identity the limit belongs to, or null when it is global.</param>
/// <param name="Kind">How the limit is set.</param>
/// <param name="Device">The execution target the limit applies to.</param>
/// <param name="Minimum">The smallest accepted value, or null when there is none.</param>
/// <param name="Maximum">The largest accepted value, or null when there is none.</param>
/// <param name="Value">The resolved current value, or null when it depends on the inputs.</param>
/// <param name="Unit">The unit of the values, such as <c>bytes</c>, <c>rows</c> or <c>nodes</c>.</param>
/// <param name="Option">The option property that sets the limit, such as <c>MathBlocksCudaOptions.MaximumGridX</c>, or null.</param>
/// <param name="DrivenBy">The names of the limits a derived value follows from; empty otherwise.</param>
/// <param name="Rule">One sentence: the derivation, the domain rule, or "speed-only; results unchanged".</param>
public sealed record MathBlockLimit(
    string Name,
    string? Operation,
    MathBlockLimitKind Kind,
    MathBlockLimitDevice Device,
    long? Minimum,
    long? Maximum,
    long? Value,
    string Unit,
    string? Option,
    IReadOnlyList<string> DrivenBy,
    string Rule);
