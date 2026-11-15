namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// Writes the proof tables and the provenance notes. The folder is the experiments folder of the proof run when its parent exists,
/// <c>MATHBLOCKS_PROOF_OUT</c> when that variable is set, and the test output folder otherwise.
/// </summary>
internal static class ProofReport
{
    private const string DefaultFolder = "/home/claude/MathBlocks-Overwatch/projects/mathblocks/experiments/2026-11-15-proof";

    /// <summary>Writes a text file into the report folder and returns its path.</summary>
    internal static string WriteText(string fileName, string text)
    {
        var folder = Folder();
        Directory.CreateDirectory(folder);
        var path = Path.Combine(folder, fileName);
        File.WriteAllText(path, text);
        return path;
    }

    private static string Folder()
    {
        var configured = Environment.GetEnvironmentVariable("MATHBLOCKS_PROOF_OUT");
        if (!string.IsNullOrEmpty(configured))
            return configured;
        var parent = Path.GetDirectoryName(DefaultFolder);
        return parent is not null && Directory.Exists(parent) ? DefaultFolder : Path.Combine(AppContext.BaseDirectory, "proof");
    }
}
