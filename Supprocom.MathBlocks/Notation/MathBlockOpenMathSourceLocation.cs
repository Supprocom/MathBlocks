using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one source position in a Profile 1 document.</summary>
[DebuggerDisplay("{ProfilePath}, line {Line}, column {Column}")]
public sealed class MathBlockOpenMathSourceLocation
{
    internal MathBlockOpenMathSourceLocation(string profilePath, int line, int column)
    {
        ProfilePath = profilePath;
        Line = line;
        Column = column;
    }

    /// <summary>Gets the stable Profile 1 path.</summary>
    public string ProfilePath { get; }

    /// <summary>Gets the one-based line number.</summary>
    public int Line { get; }

    /// <summary>Gets the one-based column number.</summary>
    public int Column { get; }
}
