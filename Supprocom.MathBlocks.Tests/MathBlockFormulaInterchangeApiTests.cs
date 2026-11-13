using System.Buffers;
using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Formula Interchange Api Tests.</summary>
public sealed class MathBlockFormulaInterchangeApiTests
{
    /// <summary>Verifies public apicontains the reviewed 050 surface.</summary>
    [Fact]
    public void PublicAPIContainsTheReviewed050Surface()
    {
        var methods = typeof(MathBlockFormulaInterchange)
            .GetMethods(BindingFlags.Public | BindingFlags.Static | BindingFlags.DeclaredOnly)
            .Where(method => !method.IsSpecialName)
            .ToArray();

        Assert.Equal(57, methods.Length);
        Assert.Equal(
            new Dictionary<string, int>(StringComparer.Ordinal)
            {
                ["Export"] = 2,
                ["ExportUtf8"] = 2,
                ["GetUtf8ByteCount"] = 2,
                ["Import"] = 4,
                ["ImportUtf8"] = 6,
                ["Normalize"] = 2,
                ["NormalizeUtf8"] = 2,
                ["Read"] = 2,
                ["ReadAsync"] = 2,
                ["ReadUtf8"] = 2,
                ["ReadUtf8Async"] = 2,
                ["SelectProfile"] = 1,
                ["TryGetOperation"] = 1,
                ["TryGetOperationMapping"] = 1,
                ["TryImport"] = 2,
                ["TryImportUtf8"] = 4,
                ["TryRead"] = 2,
                ["TryReadUtf8"] = 2,
                ["TryWriteUtf8"] = 2,
                ["Validate"] = 2,
                ["ValidateProgram"] = 2,
                ["ValidateUtf8"] = 2,
                ["Write"] = 2,
                ["WriteAsync"] = 1,
                ["WriteUtf8"] = 4,
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

    /// <summary>Verifies public formula types are the reviewed set.</summary>
    [Fact]
    public void PublicFormulaTypesAreTheReviewedSet()
    {
        var names = typeof(MathBlockFormulaInterchange).Assembly
            .GetExportedTypes()
            .Where(type => string.Equals(type.Namespace, typeof(MathBlockFormulaInterchange).Namespace, StringComparison.Ordinal))
            .Select(type => type.Name)
            .Where(name => name.StartsWith("MathBlockFormula", StringComparison.Ordinal))
            .Order(StringComparer.Ordinal)
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
                "MathBlockFormulaInterchangeOptions",
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
