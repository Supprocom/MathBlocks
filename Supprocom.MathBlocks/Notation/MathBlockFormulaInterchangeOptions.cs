using System.Globalization;

namespace Supprocom.MathBlocks;

/// <summary>Specifies the size ceilings of a formula import: document length, visible-expression size and the OpenMath limits of the exact annotation.</summary>
/// <remarks>Every default is the ceiling earlier versions fixed. A value above the real .NET limit it is bounded by throws <see cref="ArgumentOutOfRangeException"/> when an import receives the options.</remarks>
public sealed class MathBlockFormulaInterchangeOptions
{
    // The longest .NET string: 0x3FFFFFDF characters.
    internal const int MaximumStringLength = MathBlockOpenMathImportOptions.MaximumStringLength;

    /// <summary>Gets the option set with today's ceilings.</summary>
    public static MathBlockFormulaInterchangeOptions Default { get; } = new();

    /// <summary>Gets the maximum number of decoded formula-document characters. The range is 1 to 1,073,741,791, the longest .NET string.</summary>
    public int MaximumDocumentCharacters { get; init; } = MathBlockFormulaInterchange.MaximumDocumentCharacters;

    /// <summary>Gets the maximum number of formula-document UTF-8 bytes. The range is 1 to 2,147,483,591, the longest .NET byte array.</summary>
    public int MaximumDocumentUtf8Bytes { get; init; } = MathBlockFormulaInterchange.MaximumDocumentUtf8Bytes;

    /// <summary>Gets the maximum number of buffered visible-expression elements. The range is 1 to 2,147,483,591, the longest .NET array.</summary>
    public int MaximumExpressionElements { get; init; } = MathBlockFormulaInterchange.MaximumExpressionElements;

    /// <summary>Gets the maximum visible-expression nesting depth. The range is 1 to 2,147,483,591, the longest .NET array, because each level is a buffered element; the parser also needs one stack frame set per level, and an expression deeper than the stack allows is rejected as a <see cref="FormatException"/>.</summary>
    public int MaximumExpressionDepth { get; init; } = MathBlockFormulaInterchange.MaximumExpressionDepth;

    /// <summary>Gets the OpenMath import options applied to the exact annotation, or <see cref="MathBlockOpenMathImportOptions.Default"/> when null.</summary>
    public MathBlockOpenMathImportOptions? OpenMath { get; init; }

    // Throws ArgumentOutOfRangeException naming the option and the .NET limit that bounds it.
    internal void Validate()
    {
        RequireRange(MaximumDocumentCharacters, MaximumStringLength, nameof(MaximumDocumentCharacters), "the longest .NET string");
        RequireRange(MaximumDocumentUtf8Bytes, Array.MaxLength, nameof(MaximumDocumentUtf8Bytes), "the longest .NET byte array");
        RequireRange(MaximumExpressionElements, Array.MaxLength, nameof(MaximumExpressionElements), "the longest .NET array");
        RequireRange(MaximumExpressionDepth, Array.MaxLength, nameof(MaximumExpressionDepth), "the longest .NET array");
    }

    internal MathBlockOpenMathImportOptions OpenMathOptions => OpenMath ?? MathBlockOpenMathImportOptions.Default;

    private static void RequireRange(int value, int maximum, string name, string limit)
    {
        if (value < 1 || value > maximum)
        {
            throw new ArgumentOutOfRangeException(
                name,
                value,
                string.Create(
                    CultureInfo.InvariantCulture,
                    $"{name} must be from 1 to {maximum:N0}, {limit}."));
        }
    }
}
