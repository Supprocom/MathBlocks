namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// One input class at one size. A row-function set uses <see cref="First"/> and <see cref="Second"/> as the two operands. A sequence set uses
/// <see cref="First"/> as the series, <see cref="Predicate"/> as the first-true predicate and <see cref="Available"/> as the series' per-row availability.
/// </summary>
/// <param name="name">The class name.</param>
/// <param name="first">The first operand or the series.</param>
/// <param name="second">The second operand, empty for a sequence set.</param>
/// <param name="predicate">The predicate series, empty for a row-function set.</param>
/// <param name="available">The per-row availability, empty for a row-function set.</param>
internal sealed class ProofSet(string name, double[] first, double[] second, double[] predicate, bool[] available)
{
    /// <summary>Gets the class name.</summary>
    internal string Name { get; } = name;

    /// <summary>Gets the first operand or the series.</summary>
    internal double[] First { get; } = first;

    /// <summary>Gets the second operand.</summary>
    internal double[] Second { get; } = second;

    /// <summary>Gets the predicate series.</summary>
    internal double[] Predicate { get; } = predicate;

    /// <summary>Gets the per-row availability.</summary>
    internal bool[] Available { get; } = available;
}
