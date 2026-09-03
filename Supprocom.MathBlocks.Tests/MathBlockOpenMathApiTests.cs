using System.Buffers;
using System.Reflection;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockOpenMathApiTests
{
    [Fact]
    public void Public_API_contains_the_reviewed_additive_surface()
    {
        var methods = typeof(MathBlockOpenMath)
            .GetMethods(BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly)
            .Where(method => !method.IsSpecialName)
            .ToArray();

        Assert.Equal(37, methods.Length);
        Assert.Equal(
            new Dictionary<string, int>(StringComparer.Ordinal)
            {
                ["Export"] = 1,
                ["ExportUtf8"] = 1,
                ["GetUtf8ByteCount"] = 1,
                ["Import"] = 2,
                ["ImportUtf8"] = 2,
                ["Normalize"] = 2,
                ["NormalizeAsync"] = 1,
                ["NormalizeUtf8"] = 3,
                ["NormalizeUtf8Async"] = 1,
                ["Read"] = 1,
                ["ReadAsync"] = 1,
                ["ReadUtf8"] = 1,
                ["ReadUtf8Async"] = 1,
                ["TryGetOperation"] = 1,
                ["TryGetOperationSymbol"] = 1,
                ["TryImport"] = 1,
                ["TryImportUtf8"] = 2,
                ["TryRead"] = 1,
                ["TryReadAsync"] = 1,
                ["TryReadUtf8"] = 1,
                ["TryReadUtf8Async"] = 1,
                ["TryWriteUtf8"] = 1,
                ["Validate"] = 1,
                ["ValidateProgram"] = 1,
                ["ValidateUtf8"] = 2,
                ["Write"] = 1,
                ["WriteAsync"] = 1,
                ["WriteUtf8"] = 2,
                ["WriteUtf8Async"] = 1
            },
            methods
                .GroupBy(method => method.Name, StringComparer.Ordinal)
                .ToDictionary(group => group.Key, group => group.Count(), StringComparer.Ordinal));

        RequireMethod("Export", typeof(string), typeof(MathBlockProgram));
        RequireMethod("Import", typeof(MathBlockOpenMathImportResult), typeof(string));
        RequireMethod(
            "Import",
            typeof(MathBlockOpenMathImportResult),
            typeof(string),
            typeof(MathBlockOpenMathImportOptions));
        RequireMethod("ExportUtf8", typeof(byte[]), typeof(MathBlockProgram));
        RequireMethod("GetUtf8ByteCount", typeof(int), typeof(MathBlockProgram));
        RequireMethod(
            "TryWriteUtf8",
            typeof(bool),
            typeof(MathBlockProgram),
            typeof(Span<byte>),
            typeof(int).MakeByRefType());
        RequireMethod(
            "WriteUtf8",
            typeof(void),
            typeof(MathBlockProgram),
            typeof(IBufferWriter<byte>));
        RequireMethod(
            "WriteUtf8",
            typeof(void),
            typeof(MathBlockProgram),
            typeof(Stream));
        RequireMethod(
            "WriteUtf8Async",
            typeof(Task),
            typeof(MathBlockProgram),
            typeof(Stream),
            typeof(CancellationToken));
        RequireMethod(
            "Write",
            typeof(void),
            typeof(MathBlockProgram),
            typeof(TextWriter));
        RequireMethod(
            "WriteAsync",
            typeof(Task),
            typeof(MathBlockProgram),
            typeof(TextWriter),
            typeof(CancellationToken));
        RequireMethod(
            "ImportUtf8",
            typeof(MathBlockOpenMathImportResult),
            typeof(ReadOnlySpan<byte>),
            typeof(MathBlockOpenMathImportOptions));
        RequireMethod(
            "ImportUtf8",
            typeof(MathBlockOpenMathImportResult),
            typeof(ReadOnlySequence<byte>),
            typeof(MathBlockOpenMathImportOptions));
        RequireMethod(
            "ReadUtf8",
            typeof(MathBlockOpenMathImportResult),
            typeof(Stream),
            typeof(MathBlockOpenMathImportOptions));
        RequireMethod(
            "ReadUtf8Async",
            typeof(Task<MathBlockOpenMathImportResult>),
            typeof(Stream),
            typeof(MathBlockOpenMathImportOptions),
            typeof(CancellationToken));
        RequireMethod(
            "Read",
            typeof(MathBlockOpenMathImportResult),
            typeof(TextReader),
            typeof(MathBlockOpenMathImportOptions));
        RequireMethod(
            "ReadAsync",
            typeof(Task<MathBlockOpenMathImportResult>),
            typeof(TextReader),
            typeof(MathBlockOpenMathImportOptions),
            typeof(CancellationToken));
        RequireMethod(
            "ValidateProgram",
            typeof(MathBlockOpenMathProgramValidationResult),
            typeof(MathBlockProgram));
        RequireMethod(
            "TryGetOperationSymbol",
            typeof(bool),
            typeof(MathBlockOperation),
            typeof(MathBlockOpenMathOperationSymbol).MakeByRefType());
        RequireMethod(
            "TryGetOperation",
            typeof(bool),
            typeof(MathBlockOpenMathOperationSymbol),
            typeof(MathBlockOperation).MakeByRefType());

        Assert.Throws<ArgumentNullException>(() => MathBlockOpenMath.Import(null!));
    }

    [Fact]
    public void Public_OpenMath_types_are_the_reviewed_set()
    {
        var names = typeof(MathBlockOpenMath).Assembly
            .GetExportedTypes()
            .Where(type => type.Namespace == typeof(MathBlockOpenMath).Namespace)
            .Select(type => type.Name)
            .Where(name => name.StartsWith("MathBlockOpenMath", StringComparison.Ordinal))
            .OrderBy(name => name, StringComparer.Ordinal)
            .ToArray();

        Assert.Equal(
            [
                "MathBlockOpenMath",
                "MathBlockOpenMathCanonicality",
                "MathBlockOpenMathDiagnostic",
                "MathBlockOpenMathDiagnosticCode",
                "MathBlockOpenMathDifferenceUnit",
                "MathBlockOpenMathImportAttempt",
                "MathBlockOpenMathImportOptions",
                "MathBlockOpenMathImportResult",
                "MathBlockOpenMathOperationDefinition",
                "MathBlockOpenMathOperationOccurrence",
                "MathBlockOpenMathOperationSymbol",
                "MathBlockOpenMathProfileArtifact",
                "MathBlockOpenMathProfileDescriptor",
                "MathBlockOpenMathProgramValidationResult",
                "MathBlockOpenMathSourceLocation",
                "MathBlockOpenMathValidationResult"
            ],
            names);

        Type[] resultTypes =
        [
            typeof(MathBlockOpenMathDiagnostic),
            typeof(MathBlockOpenMathImportAttempt),
            typeof(MathBlockOpenMathImportResult),
            typeof(MathBlockOpenMathOperationDefinition),
            typeof(MathBlockOpenMathOperationOccurrence),
            typeof(MathBlockOpenMathProfileArtifact),
            typeof(MathBlockOpenMathProfileDescriptor),
            typeof(MathBlockOpenMathProgramValidationResult),
            typeof(MathBlockOpenMathSourceLocation),
            typeof(MathBlockOpenMathValidationResult)
        ];
        Assert.All(resultTypes, type => Assert.Empty(type.GetConstructors()));
    }

    private static void RequireMethod(string name, Type returnType, params Type[] parameterTypes)
    {
        var method = typeof(MathBlockOpenMath).GetMethod(
            name,
            BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly,
            null,
            parameterTypes,
            null);
        Assert.NotNull(method);
        Assert.Equal(returnType, method.ReturnType);
    }
}
