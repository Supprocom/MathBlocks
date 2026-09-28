using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes the first authoritative OpenMath failure.</summary>
[DebuggerDisplay("{Code}: {Message}")]
public sealed class MathBlockOpenMathDiagnostic
{
    internal MathBlockOpenMathDiagnostic(
        MathBlockOpenMathDiagnosticCode code,
        string message,
        int? line = null,
        int? column = null,
        string? profilePath = null,
        int? nodeIndex = null,
        string? operationIdentifier = null,
        string? dictionary = null,
        string? symbol = null)
    {
        Code = code;
        Message = message;
        Line = line;
        Column = column;
        ProfilePath = profilePath;
        NodeIndex = nodeIndex;
        OperationIdentifier = operationIdentifier;
        Dictionary = dictionary;
        Symbol = symbol;
    }

    /// <summary>Gets the stable diagnostic code.</summary>
    public MathBlockOpenMathDiagnosticCode Code { get; }

    /// <summary>Gets the invariant diagnostic message.</summary>
    public string Message { get; }

    /// <summary>Gets the one-based source line when it is available.</summary>
    public int? Line { get; }

    /// <summary>Gets the one-based source column when it is available.</summary>
    public int? Column { get; }

    /// <summary>Gets the stable Profile 1 path when it is available.</summary>
    public string? ProfilePath { get; }

    /// <summary>Gets the program node index when it is available.</summary>
    public int? NodeIndex { get; }

    /// <summary>Gets the operation identity when it is available.</summary>
    public string? OperationIdentifier { get; }

    /// <summary>Gets the content dictionary when it is available.</summary>
    public string? Dictionary { get; }

    /// <summary>Gets the symbol name when it is available.</summary>
    public string? Symbol { get; }

    /// <inheritdoc />
    public override string ToString() => string.Concat(Code, ": ", Message);
}
