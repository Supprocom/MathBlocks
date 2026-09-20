using System.Buffers;
using System.Reflection;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockFormulaInterchangeApiTests
{
    [Fact]
    public void Public_API_contains_the_reviewed_0_5_0_surface()
    {
        var methods = typeof(MathBlockFormulaInterchange)
            .GetMethods(BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly)
            .Where(method => !method.IsSpecialName)
            .ToArray();

        Assert.Equal(30, methods.Length);
        Assert.Equal(
            new Dictionary<string, int>(StringComparer.Ordinal)
            {
                ["Export"] = 1,
                ["ExportUtf8"] = 1,
                ["GetUtf8ByteCount"] = 1,
                ["Import"] = 2,
                ["ImportUtf8"] = 3,
                ["Normalize"] = 1,
                ["NormalizeUtf8"] = 1,
                ["Read"] = 1,
                ["ReadAsync"] = 1,
                ["ReadUtf8"] = 1,
                ["ReadUtf8Async"] = 1,
                ["TryGetOperation"] = 1,
                ["TryGetOperationMapping"] = 1,
                ["TryImport"] = 1,
                ["TryImportUtf8"] = 2,
                ["TryRead"] = 1,
                ["TryReadUtf8"] = 1,
                ["TryWriteUtf8"] = 1,
                ["Validate"] = 1,
                ["ValidateProgram"] = 1,
                ["ValidateUtf8"] = 1,
                ["Write"] = 1,
                ["WriteAsync"] = 1,
                ["WriteUtf8"] = 2,
                ["WriteUtf8Async"] = 1
            },
            methods
                .GroupBy(method => method.Name, StringComparer.Ordinal)
                .ToDictionary(group => group.Key, group => group.Count(), StringComparer.Ordinal));

        RequireMethod(
            "Export",
            typeof(string),
            typeof(MathBlockProgram),
            typeof(string),
            typeof(MathBlockFormulaFormat));
        RequireMethod(
            "Import",
            typeof(MathBlockFormulaImportResult),
            typeof(string),
            typeof(MathBlockFormulaFormat));
        RequireMethod(
            "Import",
            typeof(MathBlockFormulaImportResult),
            typeof(string),
            typeof(MathBlockFormulaFormat),
            typeof(IReadOnlyDictionary<string, MathBlockType>),
            typeof(string));
        RequireMethod(
            "ImportUtf8",
            typeof(MathBlockFormulaImportResult),
            typeof(ReadOnlySpan<byte>),
            typeof(MathBlockFormulaFormat));
        RequireMethod(
            "ImportUtf8",
            typeof(MathBlockFormulaImportResult),
            typeof(ReadOnlySequence<byte>),
            typeof(MathBlockFormulaFormat));
        RequireMethod(
            "ImportUtf8",
            typeof(MathBlockFormulaImportResult),
            typeof(ReadOnlySpan<byte>),
            typeof(MathBlockFormulaFormat),
            typeof(IReadOnlyDictionary<string, MathBlockType>),
            typeof(string));
        RequireMethod(
            "TryWriteUtf8",
            typeof(bool),
            typeof(MathBlockProgram),
            typeof(string),
            typeof(MathBlockFormulaFormat),
            typeof(Span<byte>),
            typeof(int).MakeByRefType());
        RequireMethod(
            "ReadUtf8Async",
            typeof(Task<MathBlockFormulaImportResult>),
            typeof(Stream),
            typeof(MathBlockFormulaFormat),
            typeof(CancellationToken));
        RequireMethod(
            "ValidateProgram",
            typeof(MathBlockFormulaValidationResult),
            typeof(MathBlockProgram),
            typeof(string),
            typeof(MathBlockFormulaFormat));
    }

    [Fact]
    public void Public_formula_types_are_the_reviewed_set()
    {
        var names = typeof(MathBlockFormulaInterchange).Assembly
            .GetExportedTypes()
            .Where(type => type.Namespace == typeof(MathBlockFormulaInterchange).Namespace)
            .Select(type => type.Name)
            .Where(name => name.StartsWith("MathBlockFormula", StringComparison.Ordinal))
            .OrderBy(name => name, StringComparer.Ordinal)
            .ToArray();

        Assert.Equal(
            [
                "MathBlockFormulaBuilder",
                "MathBlockFormulaDiagnostic",
                "MathBlockFormulaDiagnosticCode",
                "MathBlockFormulaFormat",
                "MathBlockFormulaImportAttempt",
                "MathBlockFormulaImportResult",
                "MathBlockFormulaInterchange",
                "MathBlockFormulaMappingClassification",
                "MathBlockFormulaMappingKind",
                "MathBlockFormulaOperationMapping",
                "MathBlockFormulaProfileArtifact",
                "MathBlockFormulaProfileDescriptor",
                "MathBlockFormulaSymbol",
                "MathBlockFormulaValidationResult"
            ],
            names);

        Type[] resultTypes =
        [
            typeof(MathBlockFormulaDiagnostic),
            typeof(MathBlockFormulaImportAttempt),
            typeof(MathBlockFormulaImportResult),
            typeof(MathBlockFormulaOperationMapping),
            typeof(MathBlockFormulaProfileArtifact),
            typeof(MathBlockFormulaProfileDescriptor),
            typeof(MathBlockFormulaValidationResult)
        ];
        Assert.All(resultTypes, type => Assert.Empty(type.GetConstructors()));
    }

    private static void RequireMethod(string name, Type returnType, params Type[] parameterTypes)
    {
        var method = typeof(MathBlockFormulaInterchange).GetMethod(
            name,
            BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly,
            null,
            parameterTypes,
            null);
        Assert.NotNull(method);
        Assert.Equal(returnType, method.ReturnType);
    }
}
