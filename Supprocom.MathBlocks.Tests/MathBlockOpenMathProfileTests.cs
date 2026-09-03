using System.Security.Cryptography;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockOpenMathProfileTests
{
    [Fact]
    public void Profile_descriptor_binds_every_standard_operation_in_order()
    {
        var profile = MathBlockOpenMath.Profile;

        Assert.Equal(MathBlockOpenMath.StandardVersion, profile.StandardVersion);
        Assert.Equal(MathBlockOpenMath.ProfileVersion, profile.ProfileVersion);
        Assert.Equal(MathBlockOpenMath.MediaType, profile.MediaType);
        Assert.Equal(MathBlockOpenMath.CanonicalizationAlgorithm, profile.CanonicalizationAlgorithm);
        Assert.Equal(MathBlockOpenMath.ContentDictionaryBase, profile.ContentDictionaryBase);
        Assert.Equal(MathBlockOpenMath.ContentDictionaryGroup, profile.ContentDictionaryGroup);
        Assert.Equal(337, profile.Operations.Count);

        for (var index = 0; index < profile.Operations.Count; index++)
        {
            var definition = profile.Operations[index];
            var operation = MathBlockCatalog.Standard.Operations[index];
            Assert.Same(operation, definition.Operation);
            Assert.Equal(operation.Identity, definition.Identity);
            Assert.Equal(operation.Arity, definition.Arity);
            Assert.True(MathBlockOpenMath.TryGetOperationSymbol(operation, out var symbol));
            Assert.Equal(definition.Symbol, symbol);
            Assert.True(MathBlockOpenMath.TryGetOperation(symbol, out var resolved));
            Assert.Same(operation, resolved);
        }
    }

    [Fact]
    public void Operation_lookup_requires_the_exact_standard_instance()
    {
        var standard = MathBlockCatalog.Standard.Operations[0];
        var copied = new MathBlockOperation(
            standard.Identifier,
            standard.Version,
            standard.Arity,
            types => types[0],
            inputs => inputs[0],
            standard.RegressionCases,
            standard.PerformanceCase);

        Assert.False(MathBlockOpenMath.TryGetOperationSymbol(copied, out var copiedSymbol));
        Assert.Equal(default, copiedSymbol);
        Assert.False(MathBlockOpenMath.TryGetOperation(default, out var missing));
        Assert.Null(missing);
        Assert.False(MathBlockOpenMath.TryGetOperation(
            new MathBlockOpenMathOperationSymbol("arith1", "plus"),
            out missing));
        Assert.Null(missing);
    }

    [Fact]
    public void Embedded_profile_artifacts_match_the_tracked_profile()
    {
        var artifacts = MathBlockOpenMath.Profile.Artifacts;
        Assert.Equal(7, artifacts.Count);
        Assert.Equal(
            [
                "mathblocks_operations1.ocd",
                "mathblocks_profile1.cdg",
                "mathblocks_profile1.rnc",
                "mathblocks_program1.ocd",
                "mathblocks_types1.ocd",
                "mathblocks_values1.ocd",
                "README.md"
            ],
            artifacts.Select(artifact => artifact.Name));

        foreach (var artifact in artifacts)
        {
            var tracked = File.ReadAllBytes(ProfilePath(artifact.Name));
            using var first = artifact.OpenRead();
            using var second = artifact.OpenRead();
            using var buffer = new MemoryStream();
            first.CopyTo(buffer);

            Assert.NotSame(first, second);
            Assert.False(first.CanWrite);
            Assert.False(second.CanWrite);
            Assert.Equal(0, second.Position);
            Assert.Equal(tracked.Length, artifact.Length);
            Assert.Equal(string.Concat("openmath/v1/", artifact.Name), artifact.PackagePath);
            Assert.Equal(tracked, buffer.ToArray());
            Assert.Equal(
                Convert.ToHexString(SHA256.HashData(tracked)),
                artifact.Sha256);
            Assert.Equal(!artifact.Name.EndsWith(".md", StringComparison.Ordinal), artifact.IsNormative);
        }
    }

    [Fact]
    public void Profile_collections_are_read_only()
    {
        var operations = Assert.IsAssignableFrom<IList<MathBlockOpenMathOperationDefinition>>(
            MathBlockOpenMath.Profile.Operations);
        var artifacts = Assert.IsAssignableFrom<IList<MathBlockOpenMathProfileArtifact>>(
            MathBlockOpenMath.Profile.Artifacts);

        Assert.True(operations.IsReadOnly);
        Assert.True(artifacts.IsReadOnly);
        Assert.Throws<NotSupportedException>(() => operations.Clear());
        Assert.Throws<NotSupportedException>(() => artifacts.Clear());
    }

    private static string ProfilePath(string name) =>
        Path.Combine(AppContext.BaseDirectory, "openmath", "v1", name);
}
