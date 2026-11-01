using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies without a device that every operation identity named in the CUDA test data exists. A CUDA test resolves its identity
/// (<c>MathBlockCudaDeviceModule.GetOperation</c>, <c>MathBlockCatalog.Standard.Get</c>) before it reaches the device, so a misspelt or invented
/// identity fails the test in the device run after the lock is taken. The check reads every string literal of the CUDA test sources that has the shape
/// of an operation identity (a known family prefix, dotted words, optional <c>@version</c>, optional <c>/case</c> suffix) and requires it to be a
/// CUDA operation of the device module and an operation of the Standard catalog.
/// </summary>
public sealed partial class MathBlockCudaTestIdentityTests
{
    [GeneratedRegex("\"(?<name>[a-z][a-z0-9-]*(?:\\.[a-z0-9-]+)+)(?<version>@[0-9]+)?(?:/[^\"]*)?\"", RegexOptions.CultureInvariant, matchTimeoutMilliseconds: 10_000)]
    private static partial Regex Literal();

    // String literals that have the shape of an identity but are not a contract identity: a file name, and the window batch test's own version 2 operation.
    private static readonly HashSet<string> NotIdentities = new(StringComparer.Ordinal) { "base-opcode-dispatch.cu", "window-accurate.sum" };

    /// <summary>Verifies every identity named in the CUDA test sources is a CUDA operation.</summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void EveryOperationIdentityNamedInTheCUDATestDataExists()
    {
        var contracts = MathBlockCudaDeviceModule.Operations.Select(item => item.Identity).ToHashSet(StringComparer.Ordinal);
        var families = contracts.Select(identity => identity[..identity.IndexOf('.', StringComparison.Ordinal)]).ToHashSet(StringComparer.Ordinal);
        var missing = new SortedSet<string>(StringComparer.Ordinal);
        var checkedNames = new HashSet<string>(StringComparer.Ordinal);
        foreach (var file in CudaTestSources())
        {
            var text = File.ReadAllText(file);
            foreach (Match match in Literal().Matches(text))
            {
                var name = match.Groups["name"].Value;
                if (NotIdentities.Contains(name) || !families.Contains(name[..name.IndexOf('.', StringComparison.Ordinal)]))
                    continue;
                var identity = match.Groups["version"].Success ? name + match.Groups["version"].Value : name + "@1";
                checkedNames.Add(identity);
                if (!contracts.Contains(identity))
                    missing.Add($"{identity} ({Path.GetFileName(file)})");
            }
        }

        Assert.True(checkedNames.Count > 100, $"Only {checkedNames.Count} identities were found in the CUDA test sources.");
        Assert.True(missing.Count == 0, "These identities named in the CUDA test data are not CUDA operations: " + string.Join("; ", missing));
        foreach (var identity in checkedNames.Where(item => !item.StartsWith("window", StringComparison.Ordinal)))
            Assert.NotNull(MathBlockCatalog.Standard.Get(identity[..identity.IndexOf('@', StringComparison.Ordinal)], 1));
    }

    private static IEnumerable<string> CudaTestSources([CallerFilePath] string sourceFile = "")
    {
        var directory = Path.GetDirectoryName(sourceFile)!;
        return Directory.EnumerateFiles(directory, "*.cs", SearchOption.TopDirectoryOnly)
            .Where(file =>
            {
                if (string.Equals(Path.GetFileName(file), "MathBlockCudaTestIdentityTests.cs", StringComparison.Ordinal))
                    return false;
                var text = File.ReadAllText(file);
                return text.Contains("CudaTestDevice.Available", StringComparison.Ordinal) ||
                    text.Contains("MathBlockCudaDeviceModule", StringComparison.Ordinal) ||
                    text.Contains("MathBlocksCUDAWorker", StringComparison.Ordinal);
            })
            .Order(StringComparer.Ordinal);
    }
}
