using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Xml.Linq;
using MathBlocks.FormulaProfileGenerator;
using MathBlocks.OpenMathProfileGenerator;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for the frozen Profile 1 and the Profile 2 interchange profiles.</summary>
public sealed class MathBlockInterchangeProfileTests
{
    // SHA-256 of the 337 Profile 1 identities, each followed by a line feed, in ordinal order.
    private const string Profile1IdentityListSha256 =
        "AC690A7C8AC7884CC8F22A6954D38C83A1E837C487344A7065763774234CAA63";

    // The ordered mapping fingerprint that formula/v1/mathblocks_formula_mappings1.xml publishes.
    private const string FormulaProfile1Fingerprint =
        "ACE8E3B8527B432BA4E6C8EB7BECE3C1CC2FF2E0F6C36873AF89D630627B73A6";

    private const string OpenMathBase = "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v";
    private const string FormulaBase = "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/formula/v";

    private static readonly MathBlockFormulaFormat[] Formats =
    [
        MathBlockFormulaFormat.OpenMath,
        MathBlockFormulaFormat.ContentMathMl
    ];

    /// <summary>Verifies the frozen Profile 1 list matches the identities its published artifacts are locked to.</summary>
    [Fact]
    public void Profile1OperationListMatchesThePublishedHashLocks()
    {
        var identities = MathBlockOpenMath.Profile.Operations
            .Select(definition => definition.Identity)
            .ToArray();

        Assert.Equal(337, identities.Length);
        Assert.Equal(identities.Order(StringComparer.Ordinal), identities, StringComparer.Ordinal);
        Assert.Equal(
            Profile1IdentityListSha256,
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(
                string.Concat(identities.Select(identity => string.Concat(identity, "\n")))))));
        Assert.Equal(
            identities,
            MathBlockFormulaInterchange.Profile.Operations.Select(mapping => mapping.Identity),
            StringComparer.Ordinal);
        Assert.Equal(FormulaProfile1Fingerprint, MathBlockFormulaInterchange.Profile.Fingerprint);

        var manifest = XDocument.Load(TrackedPath("formula", 1, "mathblocks_formula_mappings1.xml"));
        var root = Assert.IsType<XElement>(manifest.Root);
        Assert.Equal(FormulaProfile1Fingerprint, root.Attribute("fingerprint")?.Value);
        Assert.Equal(
            identities,
            root.Elements().Select(entry => entry.Attribute("identity")?.Value),
            StringComparer.Ordinal);
    }

    /// <summary>Verifies Profile 1 resolves only its frozen identities when a registry contains more operations.</summary>
    [Fact]
    public void Profile1IgnoresOperationsAddedAfterTheFrozenList()
    {
        var registry = CreateTestRegistry();
        var resolved = InvokeInternal<MathBlockOperation[]>(
            typeof(MathBlockOpenMath).Assembly.GetType(
                "Supprocom.MathBlocks.MathBlockInterchangeProfiles",
                true)!,
            "ResolveProfile1",
            registry);

        Assert.Equal(337, resolved.Length);
        Assert.Equal(
            MathBlockOpenMath.Profile.Operations.Select(definition => definition.Identity),
            resolved.Select(operation => operation.Identity),
            StringComparer.Ordinal);
        Assert.DoesNotContain(resolved, operation => operation.Identifier.StartsWith("test.", StringComparison.Ordinal));
        Assert.All(resolved, operation => Assert.Same(operation, registry.Get(operation.Identifier, operation.Version)));
    }

    /// <summary>Verifies regenerated Profile 1 artifacts are byte-identical to the tracked and embedded artifacts.</summary>
    [Fact]
    public void RegeneratedProfile1ArtifactsAreByteIdentical()
    {
        var openMath = OpenMathProfileArtifacts.Create(1, OpenMathProfileArtifacts.Operations(1));
        Assert.Equal(5, openMath.Length);
        foreach (var artifact in openMath)
            AssertLockedArtifact(MathBlockOpenMath.Profile.Artifacts, "openmath", 1, artifact.Name, artifact.Content);

        var formula = FormulaProfileArtifacts.Create(1, FormulaProfileArtifacts.Mappings(1));
        Assert.Equal(5, formula.Length);
        foreach (var artifact in formula)
            AssertLockedArtifact(MathBlockFormulaInterchange.Profile.Artifacts, "formula", 1, artifact.Name, artifact.Content);

        Assert.All(
            MathBlockOpenMath.Profile.Artifacts,
            artifact => Assert.Equal(File.ReadAllBytes(TrackedPath("openmath", 1, artifact.Name)), ReadAll(artifact.OpenRead())));
        Assert.All(
            MathBlockFormulaInterchange.Profile.Artifacts,
            artifact => Assert.Equal(File.ReadAllBytes(TrackedPath("formula", 1, artifact.Name)), ReadAll(artifact.OpenRead())));
    }

    /// <summary>Verifies Profile 2 binds every standard operation under versioned names.</summary>
    [Fact]
    public void Profile2BindsEveryStandardOperationUnderVersionedNames()
    {
        var profile = MathBlockOpenMath.Profile2;
        var standard = MathBlockCatalog.Standard.Operations;

        Assert.Equal("2", profile.ProfileVersion);
        Assert.Equal(string.Concat(OpenMathBase, "2"), profile.ContentDictionaryBase);
        Assert.Equal(string.Concat(OpenMathBase, "2/mathblocks_profile2.cdg"), profile.ContentDictionaryGroup);
        Assert.Equal(standard.Count, profile.Operations.Count);
        Assert.Equal([MathBlockOpenMath.Profile, profile], MathBlockOpenMath.Profiles);
        for (var index = 0; index < standard.Count; index++)
        {
            var definition = profile.Operations[index];
            Assert.Same(standard[index], definition.Operation);
            Assert.Equal("mathblocks_operations2", definition.Symbol.Dictionary);
            Assert.Equal(
                string.Concat("op.", standard[index].Identifier, ".v", standard[index].Version.ToString(System.Globalization.CultureInfo.InvariantCulture)),
                definition.Symbol.Name);
            Assert.True(profile.TryGetOperation(definition.Symbol, out var resolved));
            Assert.Same(standard[index], resolved);
        }
        foreach (var definition in MathBlockOpenMath.Profile.Operations)
        {
            Assert.True(profile.Contains(definition.Operation));
            Assert.False(profile.TryGetOperation(definition.Symbol, out _));
        }

        var formula = MathBlockFormulaInterchange.Profile2;
        Assert.Same(profile, formula.OpenMathProfile);
        Assert.Same(MathBlockOpenMath.Profile, MathBlockFormulaInterchange.Profile.OpenMathProfile);
        Assert.Equal("2", formula.ProfileVersion);
        Assert.Equal(string.Concat(FormulaBase, "2"), formula.ContentDictionaryBase);
        Assert.Equal(string.Concat(FormulaBase, "2/mathblocks_formula_profile2.cdg"), formula.ContentDictionaryGroup);
        Assert.Equal("application/vnd.supprocom.mathblocks.openmath-profile2+xml", formula.ExactAnnotationMediaType);
        Assert.Equal(MathBlockFormulaInterchange.ExactAnnotationMediaType, MathBlockFormulaInterchange.Profile.ExactAnnotationMediaType);
        Assert.Equal(standard.Count, formula.Operations.Count);
        Assert.Equal([MathBlockFormulaInterchange.Profile, formula], MathBlockFormulaInterchange.Profiles);
        for (var index = 0; index < standard.Count; index++)
        {
            var mapping = formula.Operations[index];
            Assert.Same(standard[index], mapping.Operation);
            if (mapping.Kind == MathBlockFormulaMappingKind.MathBlocksExtension)
            {
                Assert.Equal(string.Concat(FormulaBase, "2"), mapping.Symbol.ContentDictionaryBase);
                Assert.Equal("mathblocks_formula_operations2", mapping.Symbol.Dictionary);
            }
            else
            {
                Assert.True(MathBlockFormulaInterchange.Profile.TryGetOperationMapping(mapping.Operation, out var profile1Mapping));
                Assert.Equal(profile1Mapping!.Symbol, mapping.Symbol);
            }
        }
    }

    /// <summary>Verifies the Profile 2 artifacts are generated, tracked, embedded, and hash-locked consistently.</summary>
    [Fact]
    public void Profile2ArtifactsMatchTheGeneratorAndTheHashLocks()
    {
        var openMath = OpenMathProfileArtifacts.Create(2, OpenMathProfileArtifacts.Operations(2));
        foreach (var artifact in openMath)
            AssertLockedArtifact(MathBlockOpenMath.Profile2.Artifacts, "openmath", 2, artifact.Name, artifact.Content);
        Assert.Equal(
            [
                "mathblocks_operations2.ocd",
                "mathblocks_profile2.cdg",
                "mathblocks_profile2.rnc",
                "mathblocks_program2.ocd",
                "mathblocks_types2.ocd",
                "mathblocks_values2.ocd",
                "README.md"
            ],
            MathBlockOpenMath.Profile2.Artifacts.Select(artifact => artifact.Name),
            StringComparer.Ordinal);
        Assert.All(MathBlockOpenMath.Profile2.Artifacts, artifact =>
        {
            Assert.Equal(!string.Equals(artifact.Name, "README.md", StringComparison.Ordinal), artifact.IsNormative);
            Assert.Equal(string.Concat("openmath/v2/", artifact.Name), artifact.PackagePath);
            Assert.Equal(File.ReadAllBytes(TrackedPath("openmath", 2, artifact.Name)), ReadAll(artifact.OpenRead()));
        });

        var mappings = FormulaProfileArtifacts.Mappings(2);
        var formula = FormulaProfileArtifacts.Create(2, mappings);
        foreach (var artifact in formula)
            AssertLockedArtifact(MathBlockFormulaInterchange.Profile2.Artifacts, "formula", 2, artifact.Name, artifact.Content);
        Assert.Equal(
            [
                "mathblocks_formula2.ocd",
                "mathblocks_formula_mappings2.xml",
                "mathblocks_formula_mappings2.rnc",
                "mathblocks_formula_mathml2.rnc",
                "mathblocks_formula_openmath2.rnc",
                "mathblocks_formula_operations2.ocd",
                "mathblocks_formula_profile2.cdg",
                "mathblocks_formula_values2.ocd",
                "README.md"
            ],
            MathBlockFormulaInterchange.Profile2.Artifacts.Select(artifact => artifact.Name),
            StringComparer.Ordinal);
        Assert.All(MathBlockFormulaInterchange.Profile2.Artifacts, artifact =>
        {
            Assert.Equal(!string.Equals(artifact.Name, "README.md", StringComparison.Ordinal), artifact.IsNormative);
            Assert.Equal(string.Concat("formula/v2/", artifact.Name), artifact.PackagePath);
            Assert.Equal(File.ReadAllBytes(TrackedPath("formula", 2, artifact.Name)), ReadAll(artifact.OpenRead()));
        });

        Assert.Equal(
            MathBlockFormulaInterchange.Profile2.Fingerprint,
            FormulaProfileArtifacts.Fingerprint(2, mappings));
        Assert.Equal(
            MathBlockFormulaInterchange.Profile2.Operations.Select(mapping => (mapping.Identity, mapping.Kind, mapping.Symbol)),
            mappings.Select(mapping => (mapping.Operation.Identity, mapping.Kind, mapping.Symbol)));
        var manifest = XDocument.Load(TrackedPath("formula", 2, "mathblocks_formula_mappings2.xml"));
        var root = Assert.IsType<XElement>(manifest.Root);
        Assert.Equal("https://supprocom.github.io/MathBlocks/formula-mapping/2", root.Name.NamespaceName);
        Assert.Equal("2", root.Attribute("profile")?.Value);
        Assert.Equal(MathBlockFormulaInterchange.Profile2.Fingerprint, root.Attribute("fingerprint")?.Value);
        Assert.Equal(
            MathBlockCatalog.Standard.Operations.Count.ToString(System.Globalization.CultureInfo.InvariantCulture),
            root.Attribute("count")?.Value);
    }

    /// <summary>Verifies the Profile 2 schemas are the Profile 1 schemas with versioned names only.</summary>
    [Fact]
    public void Profile2SchemasAreProfile1SchemasWithVersionedNames()
    {
        Assert.Equal(
            Replace(
                File.ReadAllText(TrackedPath("openmath", 1, "mathblocks_profile1.rnc")),
                ("openmath/v1", "openmath/v2"),
                ("mathblocks_profile1.cdg", "mathblocks_profile2.cdg"),
                ("mathblocks_program1", "mathblocks_program2"),
                ("mathblocks_operations1", "mathblocks_operations2"),
                ("mathblocks_types1", "mathblocks_types2"),
                ("mathblocks_values1", "mathblocks_values2")),
            File.ReadAllText(TrackedPath("openmath", 2, "mathblocks_profile2.rnc")));
        Assert.Equal(
            Replace(
                File.ReadAllText(TrackedPath("formula", 1, "mathblocks_formula_openmath1.rnc")),
                ("formula/v1", "formula/v2"),
                ("mathblocks_formula_profile1.cdg", "mathblocks_formula_profile2.cdg"),
                ("\"mathblocks_formula1\"", "\"mathblocks_formula2\""),
                ("name { \"profile1\" }", "name { \"profile2\" }")),
            File.ReadAllText(TrackedPath("formula", 2, "mathblocks_formula_openmath2.rnc")));
        Assert.Equal(
            Replace(
                File.ReadAllText(TrackedPath("formula", 1, "mathblocks_formula_mathml1.rnc")),
                ("formula/v1", "formula/v2"),
                ("mathblocks_formula_profile1.cdg", "mathblocks_formula_profile2.cdg"),
                ("openmath-profile1+xml", "openmath-profile2+xml")),
            File.ReadAllText(TrackedPath("formula", 2, "mathblocks_formula_mathml2.rnc")));
        Assert.Equal(
            Replace(
                File.ReadAllText(TrackedPath("formula", 1, "mathblocks_formula_mappings1.rnc")),
                ("formula-mapping/1\"", "formula-mapping/2\""),
                ("attribute profile { \"1\" }", "attribute profile { \"2\" }"),
                ("attribute count { \"337\" }", string.Concat(
                    "attribute count { \"",
                    MathBlockCatalog.Standard.Operations.Count.ToString(System.Globalization.CultureInfo.InvariantCulture),
                    "\" }"))),
            File.ReadAllText(TrackedPath("formula", 2, "mathblocks_formula_mappings2.rnc")));
    }

    /// <summary>Verifies a program of Profile 1 operations exports as Profile 1, byte-identical to the explicit choice.</summary>
    [Fact]
    public void LowestProfileExportKeepsProfile1ProgramsInProfile1()
    {
        foreach (var definition in MathBlockOpenMath.Profile.Operations)
        {
            var program = CreateRegressionProgram(MathBlockCatalog.Standard, definition.Operation);
            Assert.Same(MathBlockOpenMath.Profile, MathBlockOpenMath.SelectProfile(program));
            var source = MathBlockOpenMath.Export(program);
            Assert.Equal(MathBlockOpenMath.Export(program, MathBlockOpenMath.Profile), source);
            Assert.Contains(
                "cdbase=\"https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v1\"",
                source,
                StringComparison.Ordinal);
            Assert.DoesNotContain("mathblocks_operations2", source, StringComparison.Ordinal);
            Assert.Same(MathBlockOpenMath.Profile, MathBlockOpenMath.Import(source).Profile);

            Assert.Same(MathBlockFormulaInterchange.Profile, MathBlockFormulaInterchange.SelectProfile(program, "result"));
            foreach (var format in Formats)
            {
                Assert.Equal(
                    MathBlockFormulaInterchange.Export(program, "result", format, MathBlockFormulaInterchange.Profile),
                    MathBlockFormulaInterchange.Export(program, "result", format));
            }
        }
    }

    /// <summary>Verifies every standard operation round trips through explicit Profile 2 documents.</summary>
    [Fact]
    public void EveryStandardOperationRoundTripsThroughProfile2()
    {
        var options = new MathBlockOpenMathImportOptions { RequireCanonicalSource = true };
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var program = CreateRegressionProgram(MathBlockCatalog.Standard, operation);
            var source = MathBlockOpenMath.Export(program, MathBlockOpenMath.Profile2);
            var imported = MathBlockOpenMath.Import(source, options);

            Assert.Same(MathBlockOpenMath.Profile2, imported.Profile);
            Assert.Same(operation, Assert.Single(imported.Operations));
            Assert.Equal("mathblocks_operations2", Assert.Single(imported.OperationOccurrences).Symbol.Dictionary);
            Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
            Assert.Equal(source, MathBlockOpenMath.Export(imported.Program, MathBlockOpenMath.Profile2));
            Assert.Equal(Encoding.UTF8.GetBytes(source), MathBlockOpenMath.ExportUtf8(program, MathBlockOpenMath.Profile2));
            Assert.Equal(source, MathBlockOpenMath.Normalize(source));
            var validation = MathBlockOpenMath.Validate(source);
            Assert.True(validation.IsValid);
            Assert.Equal(MathBlockOpenMathCanonicality.Canonical, validation.Canonicality);
            Assert.Contains(
                "cdbase=\"https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v2\"",
                source,
                StringComparison.Ordinal);

            foreach (var format in Formats)
            {
                var formula = MathBlockFormulaInterchange.Export(
                    program,
                    "result",
                    format,
                    MathBlockFormulaInterchange.Profile2);
                var formulaImported = MathBlockFormulaInterchange.Import(formula, format);
                Assert.Same(MathBlockFormulaInterchange.Profile2, formulaImported.Profile);
                Assert.Equal(program.Fingerprint, formulaImported.Program.Fingerprint);
                Assert.Same(operation, Assert.Single(formulaImported.Operations));
                Assert.Equal(formula, MathBlockFormulaInterchange.Normalize(formula, format));
                Assert.Contains("mathblocks_formula_profile2.cdg", formula, StringComparison.Ordinal);
                Assert.DoesNotContain("profile1", formula, StringComparison.Ordinal);
            }
        }
    }

    /// <summary>Verifies import rejects documents that mix Profile 1 and Profile 2 identifiers.</summary>
    [Fact]
    public void ImportRejectsMixedProfileIdentifiers()
    {
        var program = CreateRegressionProgram(
            MathBlockCatalog.Standard,
            MathBlockCatalog.Standard.Get("scalar.add"));
        var profile1 = MathBlockOpenMath.Export(program);
        var profile2 = MathBlockOpenMath.Export(program, MathBlockOpenMath.Profile2);

        AssertImportCode(
            profile2.Replace("openmath/v2/mathblocks_profile2.cdg", "openmath/v1/mathblocks_profile1.cdg", StringComparison.Ordinal),
            MathBlockOpenMathDiagnosticCode.UnsupportedContentDictionaryGroup);
        AssertImportCode(
            profile1.Replace("cd=\"mathblocks_operations1\"", "cd=\"mathblocks_operations2\"", StringComparison.Ordinal),
            MathBlockOpenMathDiagnosticCode.UnsupportedOperationSymbol);
        AssertImportCode(
            profile2.Replace("cd=\"mathblocks_types2\"", "cd=\"mathblocks_types1\"", StringComparison.Ordinal),
            null);
        AssertImportCode(
            profile2.Replace("openmath/v2\"", "openmath/v3\"", StringComparison.Ordinal),
            MathBlockOpenMathDiagnosticCode.UnsupportedContentDictionaryBase);

        foreach (var format in Formats)
        {
            var formula = MathBlockFormulaInterchange.Export(program, "result", format, MathBlockFormulaInterchange.Profile2);
            var mixed = formula.Replace(
                "formula/v2/mathblocks_formula_profile2.cdg",
                "formula/v1/mathblocks_formula_profile1.cdg",
                StringComparison.Ordinal);
            Assert.False(MathBlockFormulaInterchange.TryImport(mixed, format).Succeeded);
        }
    }

    /// <summary>Verifies exporting an operation outside a profile names the operation and the profile.</summary>
    [Fact]
    public void ExportOutsideAProfileNamesTheOperationAndTheProfile()
    {
        var registry = CreateTestRegistry();
        var program = CreateTestProgram(registry);

        var automatic = Assert.Throws<InvalidOperationException>(() => MathBlockOpenMath.Export(program));
        Assert.Equal(
            "The program contains operation 'test.profile2-identity@1', which is outside MathBlocks OpenMath Profile 2, the highest supported profile.",
            automatic.Message);
        var explicitProfile1 = Assert.Throws<InvalidOperationException>(
            () => MathBlockOpenMath.Export(program, MathBlockOpenMath.Profile));
        Assert.Equal(
            "The program contains operation 'test.profile2-identity@1', which is outside MathBlocks OpenMath Profile 1.",
            explicitProfile1.Message);
        Assert.Equal(
            explicitProfile1.Message,
            Assert.Throws<InvalidOperationException>(
                () => MathBlockOpenMath.ExportUtf8(program, MathBlockOpenMath.Profile)).Message);

        var validation = MathBlockOpenMath.ValidateProgram(program, MathBlockOpenMath.Profile);
        Assert.False(validation.IsValid);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.OperationOutsideProfile, validation.Diagnostic?.Code);
        Assert.Equal("test.profile2-identity@1", validation.Diagnostic?.OperationIdentifier);
        Assert.Equal(1, validation.Diagnostic?.NodeIndex);
        Assert.Equal(
            MathBlockOpenMathDiagnosticCode.OperationOutsideProfile,
            MathBlockOpenMath.ValidateProgram(program).Diagnostic?.Code);

        var formulaAutomatic = Assert.Throws<InvalidOperationException>(
            () => MathBlockFormulaInterchange.Export(program, "result", MathBlockFormulaFormat.OpenMath));
        Assert.Equal(
            "The formula contains operation 'test.profile2-identity@1', which is outside MathBlocks Formula Interchange Profile 2, the highest supported profile.",
            formulaAutomatic.Message);
        var formulaExplicit = Assert.Throws<InvalidOperationException>(
            () => MathBlockFormulaInterchange.Export(
                program,
                "result",
                MathBlockFormulaFormat.ContentMathMl,
                MathBlockFormulaInterchange.Profile));
        Assert.Equal(
            "The formula contains operation 'test.profile2-identity@1', which is outside MathBlocks Formula Interchange Profile 1.",
            formulaExplicit.Message);
        Assert.Equal(
            MathBlockFormulaDiagnosticCode.OperationOutsideProfile,
            MathBlockFormulaInterchange.ValidateProgram(
                program,
                "result",
                MathBlockFormulaFormat.OpenMath,
                MathBlockFormulaInterchange.Profile).Diagnostic?.Code);
    }

    /// <summary>Verifies the lowest-profile choice and Profile 2 handle an identity outside Profile 1.</summary>
    [Fact]
    public void LowestProfileChoiceAndProfile2HandleANewIdentity()
    {
        var registry = CreateTestRegistry();
        var testProfile2 = InvokeInternal<MathBlockOpenMathProfileDescriptor>(
            typeof(MathBlockOpenMath),
            "CreateUnpublishedProfile",
            2,
            registry);
        MathBlockOpenMathProfileDescriptor[] candidates = [MathBlockOpenMath.Profile, testProfile2];
        var standardOnly = CreateRegressionProgram(registry, registry.Get("scalar.add"));
        var withNewIdentity = CreateTestProgram(registry);

        Assert.Same(MathBlockOpenMath.Profile, SelectProfile(standardOnly, candidates));
        Assert.Equal(MathBlockOpenMath.Export(standardOnly), MathBlockOpenMath.Export(standardOnly, MathBlockOpenMath.Profile));
        Assert.Same(testProfile2, SelectProfile(withNewIdentity, candidates));

        var source = MathBlockOpenMath.Export(withNewIdentity, testProfile2);
        Assert.Contains(
            "<OMS cd=\"mathblocks_operations2\" name=\"op.test.profile2-identity.v1\"></OMS>",
            source,
            StringComparison.Ordinal);
        var imported = InvokeInternal<MathBlockOpenMathImportResult>(
            typeof(MathBlockOpenMath),
            "Import",
            source,
            new MathBlockOpenMathImportOptions { RequireCanonicalSource = true },
            candidates);
        Assert.Same(testProfile2, imported.Profile);
        Assert.Same(registry.Get("test.profile2-identity"), imported.Operations[0]);
        Assert.Equal(withNewIdentity.Fingerprint, imported.Program.Fingerprint);
        Assert.Equal(source, MathBlockOpenMath.Export(imported.Program, testProfile2));
        var published = MathBlockOpenMath.TryImport(source);
        Assert.False(published.Succeeded);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.UnsupportedOperationSymbol, published.Diagnostic?.Code);

        var generated = OpenMathProfileArtifacts.Create(2, registry.Operations);
        var dictionary = XDocument.Load(new MemoryStream(
            generated.Single(artifact => string.Equals(artifact.Name, "mathblocks_operations2.ocd", StringComparison.Ordinal)).Content));
        XNamespace cd = "http://www.openmath.org/OpenMathCD";
        var definition = dictionary.Descendants(cd + "CDDefinition")
            .Single(element => string.Equals(element.Element(cd + "Name")?.Value, "op.test.profile2-identity.v1", StringComparison.Ordinal));
        Assert.Equal(
            "This application identifies MathBlocks operation test.profile2-identity@1. It requires 1 ordered operand references.",
            definition.Element(cd + "Description")?.Value);

        var testFormula2 = InvokeInternal<MathBlockFormulaProfileDescriptor>(
            typeof(MathBlockFormulaInterchange),
            "CreateUnpublishedProfile",
            testProfile2);
        MathBlockFormulaProfileDescriptor[] formulaCandidates = [MathBlockFormulaInterchange.Profile, testFormula2];
        Assert.Same(
            MathBlockFormulaInterchange.Profile,
            InvokeInternal<MathBlockFormulaProfileDescriptor>(
                typeof(MathBlockFormulaInterchange),
                "SelectProfile",
                standardOnly,
                "result",
                formulaCandidates));
        Assert.Same(
            testFormula2,
            InvokeInternal<MathBlockFormulaProfileDescriptor>(
                typeof(MathBlockFormulaInterchange),
                "SelectProfile",
                withNewIdentity,
                "result",
                formulaCandidates));
        var mapping = Assert.Single(
            FormulaProfileArtifacts.Mappings(2, registry.Operations),
            entry => string.Equals(entry.Operation.Identity, "test.profile2-identity@1", StringComparison.Ordinal));
        Assert.Equal(MathBlockFormulaMappingKind.MathBlocksExtension, mapping.Kind);
        Assert.True(testFormula2.TryGetOperationMapping(registry.Get("test.profile2-identity"), out var runtimeMapping));
        Assert.Equal(mapping.Symbol, runtimeMapping!.Symbol);
        foreach (var format in Formats)
        {
            var formula = MathBlockFormulaInterchange.Export(withNewIdentity, "result", format, testFormula2);
            var formulaImported = InvokeInternal<MathBlockFormulaImportResult>(
                typeof(MathBlockFormulaInterchange),
                "Import",
                formula,
                format,
                formulaCandidates);
            Assert.Same(testFormula2, formulaImported.Profile);
            Assert.Equal(withNewIdentity.Fingerprint, formulaImported.Program.Fingerprint);
            Assert.False(MathBlockFormulaInterchange.TryImport(formula, format).Succeeded);
        }
    }

    private static MathBlockOpenMathProfileDescriptor SelectProfile(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor[] candidates) =>
        InvokeInternal<MathBlockOpenMathProfileDescriptor>(
            typeof(MathBlockOpenMath),
            "SelectProfile",
            program,
            candidates);

    private static void AssertImportCode(string source, MathBlockOpenMathDiagnosticCode? code)
    {
        var attempt = MathBlockOpenMath.TryImport(source);
        Assert.False(attempt.Succeeded);
        if (code is not null)
            Assert.Equal(code, attempt.Diagnostic?.Code);
    }

    private static void AssertLockedArtifact<TArtifact>(
        IReadOnlyList<TArtifact> artifacts,
        string family,
        int version,
        string name,
        byte[] generated)
        where TArtifact : class
    {
        var artifact = Assert.Single(
            artifacts,
            candidate => string.Equals((string)typeof(TArtifact).GetProperty("Name")!.GetValue(candidate)!, name, StringComparison.Ordinal));
        var sha256 = (string)typeof(TArtifact).GetProperty("Sha256")!.GetValue(artifact)!;
        Assert.Equal(sha256, Convert.ToHexString(SHA256.HashData(generated)));
        Assert.Equal(File.ReadAllBytes(TrackedPath(family, version, name)), generated);
    }

    private static MathBlockRegistry CreateTestRegistry()
    {
        var identity = new MathBlockOperation(
            "test.profile2-identity",
            1,
            1,
            types => types[0],
            inputs => inputs[0],
            [new MathBlockRegressionCase(
                "identity",
                [MathBlockValue.Scalar(1d)],
                MathBlockValue.Scalar(1d))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1d)]));
        return new MathBlockRegistry(MathBlockCatalog.Standard.Operations.Append(identity));
    }

    private static MathBlockProgram CreateTestProgram(MathBlockRegistry registry)
    {
        var builder = new MathBlockProgramBuilder(registry);
        var input = builder.Input("x", MathBlockType.Scalar());
        var identity = builder.Apply("test.profile2-identity", inputs: [input]);
        var result = builder.Apply("scalar.add", inputs: [identity, input]);
        return builder.Output("result", result).Build();
    }

    private static MathBlockProgram CreateRegressionProgram(
        MathBlockRegistry registry,
        MathBlockOperation operation)
    {
        var regression = operation.RegressionCases[0];
        var builder = new MathBlockProgramBuilder(registry);
        var inputs = new int[regression.Inputs.Count];
        for (var index = 0; index < inputs.Length; index++)
            inputs[index] = builder.Constant(regression.Inputs[index]);
        var result = builder.Apply(operation.Identifier, operation.Version, inputs);
        return builder.Output("result", result).Build();
    }

    private static T InvokeInternal<T>(Type type, string name, params object[] arguments)
    {
        var method = type
            .GetMethods(BindingFlags.NonPublic | BindingFlags.Static)
            .Single(candidate =>
                string.Equals(candidate.Name, name, StringComparison.Ordinal) &&
                candidate.GetParameters().Length == arguments.Length &&
                candidate.GetParameters()
                    .Zip(arguments)
                    .All(pair => pair.First.ParameterType.IsInstanceOfType(pair.Second)));
        try
        {
            return (T)method.Invoke(null, arguments)!;
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw exception.InnerException;
        }
    }

    private static string Replace(string source, params (string Old, string New)[] replacements)
    {
        var result = source;
        foreach (var (oldValue, newValue) in replacements)
        {
            Assert.Contains(oldValue, result, StringComparison.Ordinal);
            result = result.Replace(oldValue, newValue, StringComparison.Ordinal);
        }
        return result;
    }

    private static byte[] ReadAll(Stream stream)
    {
        using (stream)
        using (var buffer = new MemoryStream())
        {
            stream.CopyTo(buffer);
            return buffer.ToArray();
        }
    }

    private static string TrackedPath(string family, int version, string name) =>
        Path.Combine(
            AppContext.BaseDirectory,
            family,
            string.Concat("v", version.ToString(System.Globalization.CultureInfo.InvariantCulture)),
            name);
}
