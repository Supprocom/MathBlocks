using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes one formula-interchange failure.</summary>
[DebuggerDisplay("{Code}: {Message}")]
public sealed class MathBlockFormulaDiagnostic
{
    internal MathBlockFormulaDiagnostic(
        MathBlockFormulaDiagnosticCode code,
        string message)
    {
        Code = code;
        Message = message;
    }

    /// <summary>Gets the stable machine-readable code.</summary>
    public MathBlockFormulaDiagnosticCode Code { get; }

    /// <summary>Gets the invariant English message.</summary>
    public string Message { get; }

    /// <inheritdoc />
    public override string ToString() => string.Concat(Code, ": ", Message);
}
