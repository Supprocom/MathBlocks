using System.Security.Cryptography;
using System.ComponentModel;
using System.Globalization;
using System.Text;
using Supprocom.CSharp2CUDA;

internal static class Program
{
    private static readonly Unit[] Units =
    [
        new("Scalar", "ScalarModule.cs"),
        new("Vector", "VectorModule.cs"),
        new("Complex", "ComplexModule.cs"),
        new("Matrix", "MatrixModule.cs"),
        new("Probability", "ProbabilityModule.cs"),
        new("SequencePath", "SequencePathModule.cs"),
        new("Statistics", "StatisticsModule.cs"),
        new("Geometry", "GeometryModule.cs"),
        new("Graph", "GraphModule.cs"),
        new("Advanced", "AdvancedModule.cs"),
        new("Transport", "TransportModule.cs")
    ];

    private static int Main(string[] args)
    {
        try
        {
            var options = Arguments.Parse(args);
            Generate(options);
            return 0;
        }
        catch (Exception exception) when (exception is ArgumentException or IOException or
                                          UnauthorizedAccessException or InvalidOperationException)
        {
            Console.Error.WriteLine($"error={exception.Message}");
            return 1;
        }
    }

    private static void Generate(GeneratorOptions options)
    {
        var transpilationOptions = new CudaTranspilationOptions
        {
            NewLine = "\n",
            SourceRoot = Path.GetFullPath(options.TranslationRoot)
        };
        var fullSource = string.Concat(GenerateUnits(options, transpilationOptions)) + "\n" +
                         GenerateDispatch(options, transpilationOptions);
        var fullBytes = Encoding.UTF8.GetBytes(fullSource);
        var fullHash = Convert.ToHexString(SHA256.HashData(fullBytes));
        const string expectedFullHash =
            "6A6E8A49FD4DAD50A7B9007069A0D81A5957D7D6EE2C14FFB8DAE27BF18DCF84";
        if (!string.Equals(fullHash, expectedFullHash, StringComparison.Ordinal))
            throw new InvalidOperationException(
                $"Full CUDA source hash mismatch. Expected {expectedFullHash}, actual {fullHash}.");

        Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedCuda)!);
        File.WriteAllBytes(options.GeneratedCuda, fullBytes);
        Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedSource)!);
        File.WriteAllText(options.GeneratedSource, CreateGeneratedSource(fullBytes), new UTF8Encoding(false));
        WriteProtocolLine($"source-bytes={fullBytes.Length}");
        WriteProtocolLine($"source-sha256={fullHash}");
        WriteProtocolLine($"source-normalized-sha256={Hash(NormalizeLineEndings(fullSource))}");
        WriteProtocolLine("exact-source=True");
    }

    private static List<string> GenerateUnits(GeneratorOptions options, CudaTranspilationOptions transpilationOptions)
    {
        var generatedUnits = new List<string>(Units.Length);
        foreach (var unit in Units)
        {
            var result = CudaTranspiler.TranspileFile(
                Path.Combine(options.TranslationRoot, unit.SourceFile), options: transpilationOptions);
            if (!result.Succeeded)
                throw new InvalidOperationException(
                    $"{unit.Name} CUDA translation failed: {string.Join(Environment.NewLine, result.Diagnostics)}");
            var publishedUnit = NormalizeLineEndings(result.Source) + "\n";
            var golden = File.ReadAllText(Path.Combine(options.GoldenRoot, $"{unit.Name}CudaBlockCatalog.cu"), Encoding.UTF8);
            WriteUnitEvidence(options.EvidenceRoot, unit, publishedUnit[..^1]);
            AssertExact(unit.Name, publishedUnit[..^1], NormalizeLineEndings(golden));
            generatedUnits.Add(publishedUnit);
            WriteProtocolLine($"unit={unit.Name} bytes={Encoding.UTF8.GetByteCount(publishedUnit)} " +
                              $"sha256={Hash(publishedUnit)} exact=True diagnostics=0");
        }
        return generatedUnits;
    }

    private static string GenerateDispatch(GeneratorOptions options, CudaTranspilationOptions transpilationOptions)
    {
        var result = CudaTranspiler.TranspileFile(
            Path.Combine(options.TranslationRoot, "DeviceDispatchModule.cs"), options: transpilationOptions);
        if (!result.Succeeded)
            throw new InvalidOperationException(
                $"Device dispatch CUDA translation failed: {string.Join(Environment.NewLine, result.Diagnostics)}");
        var source = NormalizeLineEndings(result.Source);
        var golden = File.ReadAllText(Path.Combine(options.GoldenRoot, "DeviceDispatchCudaBlockCatalog.cu"), Encoding.UTF8);
        AssertExact("DeviceDispatch", source, NormalizeLineEndings(golden));
        WriteProtocolLine($"unit=DeviceDispatch bytes={Encoding.UTF8.GetByteCount(source)} " +
                          $"sha256={Hash(source)} exact=True diagnostics=0");
        return source;
    }

    private static void WriteProtocolLine([Localizable(false)] string message) => Console.WriteLine(message);

    private static string NormalizeLineEndings(string value) =>
        value.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n');

    private static void AssertExact(string unit, string actual, string expected)
    {
        if (string.Equals(actual, expected, StringComparison.Ordinal))
            return;

        var limit = Math.Min(actual.Length, expected.Length);
        var firstDifference = 0;
        while (firstDifference < limit && actual[firstDifference] == expected[firstDifference])
            firstDifference++;
        throw new InvalidOperationException(
            $"{unit} CUDA source differs from its golden unit at character {firstDifference}. " +
            $"Actual length={actual.Length}, expected length={expected.Length}.");
    }

    private static string CreateGeneratedSource(byte[] source)
    {
        var text = Encoding.UTF8.GetString(source);
        var builder = new StringBuilder();
        builder.AppendLine("// <auto-generated/>");
        builder.AppendLine("namespace Supprocom.MathBlocks.Cuda;");
        builder.AppendLine();
        builder.AppendLine("internal static class MathBlockCudaGeneratedSource");
        builder.AppendLine("{");
        builder.AppendLine("    public const string Source =");

        var lineStart = 0;
        while (lineStart < text.Length)
        {
            var lineEnd = lineStart;
            while (lineEnd < text.Length && text[lineEnd] is not ('\r' or '\n'))
                lineEnd++;

            builder.Append("        \"");
            AppendEscapedCSharpString(builder, text.Substring(lineStart, lineEnd - lineStart));

            if (lineEnd < text.Length)
            {
                if (text[lineEnd] == '\r' &&
                    lineEnd + 1 < text.Length &&
                    text[lineEnd + 1] == '\n')
                {
                    builder.Append("\\r\\n");
                    lineEnd += 2;
                }
                else
                {
                    builder.Append(text[lineEnd] == '\r' ? "\\r" : "\\n");
                    lineEnd++;
                }
            }

            builder.Append('"');
            builder.AppendLine(lineEnd < text.Length ? " +" : ";");
            lineStart = lineEnd;
        }

        builder.AppendLine("}");
        return builder.ToString();
    }

    private static void AppendEscapedCSharpString(StringBuilder builder, string value)
    {
        foreach (var character in value)
        {
            switch (character)
            {
                case '\\':
                    builder.Append("\\\\");
                    break;
                case '"':
                    builder.Append("\\\"");
                    break;
                case '\t':
                    builder.Append("\\t");
                    break;
                case '\r':
                    builder.Append("\\r");
                    break;
                case '\n':
                    builder.Append("\\n");
                    break;
                default:
                    if (character < ' ')
                        builder.Append("\\u").Append(((int)character).ToString("X4", CultureInfo.InvariantCulture));
                    else
                        builder.Append(character);
                    break;
            }
        }
    }

    private static void WriteUnitEvidence(string evidenceRoot, Unit unit, string source)
    {
        if (string.IsNullOrEmpty(evidenceRoot))
            return;

        Directory.CreateDirectory(evidenceRoot);
        var path = Path.Combine(evidenceRoot, $"{unit.Name}.cu");
        File.WriteAllText(path, source, new UTF8Encoding(false));
    }

    private static string Hash(string value) => Hash(Encoding.UTF8.GetBytes(value));

    private static string Hash(byte[] value) => Convert.ToHexString(SHA256.HashData(value));

    private sealed record Unit(string Name, string SourceFile);

    private sealed record GeneratorOptions(
        string TranslationRoot,
        string GoldenRoot,
        string GeneratedSource,
        string GeneratedCuda,
        string EvidenceRoot);

    private static class Arguments
    {
        public static GeneratorOptions Parse(string[] args)
        {
            var values = new Dictionary<string, string>(StringComparer.Ordinal);
            for (var index = 0; index < args.Length; index++)
            {
                if (!args[index].StartsWith("--", StringComparison.Ordinal) || index + 1 >= args.Length)
                    throw new ArgumentException("Arguments must use --name value pairs.");
                values[args[index]] = args[++index];
            }

            return new GeneratorOptions(
                Required(values, "--translation-root"),
                Required(values, "--golden-root"),
                Required(values, "--generated-source"),
                Required(values, "--generated-cuda"),
                values.GetValueOrDefault("--evidence-root", string.Empty));
        }

        private static string Required(Dictionary<string, string> values, string name) =>
            values.TryGetValue(name, out var value) && !string.IsNullOrWhiteSpace(value)
                ? value
                : throw new ArgumentException($"Missing required argument '{name}'.");
    }
}
