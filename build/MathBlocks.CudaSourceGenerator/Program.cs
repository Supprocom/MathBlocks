using System.Security.Cryptography;
using System.Text;
using Supprocom.CSharp2CUDA;

internal static class Program
{
    private static readonly Unit[] Units =
    [
        new("Scalar", "Cuda/Blocks/Scalar/ScalarCudaBlockCatalog.cs", "mathblocks_scalar"),
        new("Vector", "Cuda/Blocks/Vector/VectorCudaBlockCatalog.cs", "mathblocks_vector"),
        new("Complex", "Cuda/Blocks/Complex/ComplexCudaBlockCatalog.cs", "mathblocks_complex"),
        new("Matrix", "Cuda/Blocks/Matrix/MatrixCudaBlockCatalog.cs", "mathblocks_matrix"),
        new("Probability", "Cuda/Blocks/Probability/ProbabilityCudaBlockCatalog.cs", "mathblocks_probability"),
        new("SequencePath", "Cuda/Blocks/SequencePath/SequencePathCudaBlockCatalog.cs", "mathblocks_sequence_path"),
        new("Statistics", "Cuda/Blocks/Statistics/StatisticsCudaBlockCatalog.cs", "mathblocks_statistics"),
        new("Geometry", "Cuda/Blocks/Geometry/GeometryCudaBlockCatalog.cs", "mathblocks_geometry"),
        new("Graph", "Cuda/Blocks/Graph/GraphCudaBlockCatalog.cs", "mathblocks_graph"),
        new("Advanced", "Cuda/Blocks/Advanced/AdvancedCudaBlockCatalog.cs", "mathblocks_advanced"),
        new("Transport", "Cuda/Blocks/Transport/TransportCudaBlockCatalog.cs", "mathblocks_transport")
    ];

    private static int Main(string[] args)
    {
        try
        {
            var options = Arguments.Parse(args);
            var generatedUnits = new List<string>(Units.Length);
            var translationRoot = Path.Combine(
                Path.GetDirectoryName(options.GeneratedSource)!,
                "MathBlocks.CudaTranslationUnits");
            Directory.CreateDirectory(translationRoot);

            foreach (var unit in Units)
            {
                var sourcePath = Path.Combine(options.SourceRoot, unit.SourcePath.Replace('/', Path.DirectorySeparatorChar));
                var source = ExtractTranslationUnit(sourcePath);
                var translationPath = WriteTranslationUnit(
                    translationRoot,
                    Path.GetFileName(sourcePath),
                    source);
                var result = CudaTranspiler.TranspileFile(
                    translationPath,
                    options: new CudaTranspilationOptions { NewLine = "\n" });
                if (!result.Succeeded)
                {
                    throw new InvalidOperationException(
                        $"{unit.Name} CUDA translation failed: {string.Join(Environment.NewLine, result.Diagnostics)}");
                }

                var deviceSource = ToDeviceSource(result.Source, unit.EntryPoint);
                var publishedUnit = deviceSource + "\n";
                var goldenPath = Path.Combine(options.GoldenRoot, $"{unit.Name}CudaBlockCatalog.cu");
                var golden = File.ReadAllText(goldenPath, Encoding.UTF8);

                AssertExact(unit.Name, NormalizeLineEndings(deviceSource), NormalizeLineEndings(golden));
                generatedUnits.Add(publishedUnit);
                WriteUnitEvidence(options.EvidenceRoot, unit, deviceSource);
                Console.WriteLine(
                    $"unit={unit.Name} bytes={Encoding.UTF8.GetByteCount(publishedUnit)} " +
                    $"sha256={Hash(publishedUnit)} exact=True diagnostics=0");
            }

            var dispatchSourcePath = Path.Combine(
                options.SourceRoot,
                "Cuda/Blocks/DeviceDispatch/DeviceDispatchCudaBlockCatalog.cs".Replace('/', Path.DirectorySeparatorChar));
            var dispatchSource = ExtractTranslationUnit(dispatchSourcePath);
            var dispatchTranslationPath = WriteTranslationUnit(
                translationRoot,
                Path.GetFileName(dispatchSourcePath),
                dispatchSource);
            var dispatchResult = CudaTranspiler.TranspileFile(
                dispatchTranslationPath,
                options: new CudaTranspilationOptions { NewLine = "\n" });
            if (!dispatchResult.Succeeded)
            {
                throw new InvalidOperationException(
                    $"Device dispatch CUDA translation failed: {string.Join(Environment.NewLine, dispatchResult.Diagnostics)}");
            }

            var publishedDispatch = NormalizeLineEndings(dispatchResult.Source);
            var dispatchGoldenPath = Path.Combine(options.GoldenRoot, "DeviceDispatchCudaBlockCatalog.cu");
            var dispatchGolden = File.ReadAllText(dispatchGoldenPath, Encoding.UTF8);
            AssertExact(
                "DeviceDispatch",
                NormalizeLineEndings(publishedDispatch),
                NormalizeLineEndings(dispatchGolden));
            Console.WriteLine(
                $"unit=DeviceDispatch bytes={Encoding.UTF8.GetByteCount(publishedDispatch)} " +
                $"sha256={Hash(publishedDispatch)} exact=True diagnostics=0");

            var fullSource = string.Concat(generatedUnits) + "\n" + publishedDispatch;
            var fullBytes = Encoding.UTF8.GetBytes(fullSource);
            var fullHash = Convert.ToHexString(SHA256.HashData(fullBytes));
            const string expectedFullHash =
                "EEFF3D494A9F8499F66164DAEA5BA8BA7C813D2E37A0357987A4BC46A13DA92A";
            if (!string.Equals(fullHash, expectedFullHash, StringComparison.Ordinal))
            {
                throw new InvalidOperationException(
                    $"Full CUDA source hash mismatch. Expected {expectedFullHash}, actual {fullHash}.");
            }

            Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedCuda)!);
            File.WriteAllBytes(options.GeneratedCuda, fullBytes);
            Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedSource)!);
            File.WriteAllText(options.GeneratedSource, CreateGeneratedSource(fullBytes), new UTF8Encoding(false));

            Console.WriteLine($"source-bytes={fullBytes.Length}");
            Console.WriteLine($"source-sha256={fullHash}");
            Console.WriteLine($"source-normalized-sha256={Hash(NormalizeLineEndings(fullSource))}");
            Console.WriteLine("exact-source=True");
            return 0;
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine($"error={exception.Message}");
            return 1;
        }
    }

    private static string ExtractTranslationUnit(string path)
    {
        var text = NormalizeLineEndings(File.ReadAllText(path, Encoding.UTF8));
        const string marker = "private const string TranslationUnitSource = \"\"\"";
        var start = text.IndexOf(marker, StringComparison.Ordinal);
        if (start < 0)
            throw new InvalidOperationException($"Translation unit marker is missing from '{path}'.");

        var bodyStart = text.IndexOf('\n', start + marker.Length);
        if (bodyStart < 0)
            throw new InvalidOperationException($"Translation unit body is missing from '{path}'.");
        bodyStart++;

        var end = text.IndexOf("\n    \"\"\";", bodyStart, StringComparison.Ordinal);
        if (end < 0)
            end = text.IndexOf("\n\"\"\";", bodyStart, StringComparison.Ordinal);
        if (end < 0)
            throw new InvalidOperationException($"Translation unit terminator is missing from '{path}'.");

        var lines = text[bodyStart..end].Split('\n');
        for (var index = 0; index < lines.Length; index++)
        {
            if (lines[index].Length == 0)
                continue;
            if (lines[index].StartsWith("    ", StringComparison.Ordinal))
                lines[index] = lines[index][4..];
            else if (string.IsNullOrWhiteSpace(lines[index]))
                lines[index] = string.Empty;
        }

        return string.Join('\n', lines);
    }

    private static string WriteTranslationUnit(string root, string fileName, string source)
    {
        var path = Path.Combine(root, fileName);
        File.WriteAllText(
            path,
            "#pragma warning disable CS0078, CS0649\n\n" + source,
            new UTF8Encoding(false));
        return path;
    }

    private static string ToDeviceSource(string source, string entryPoint)
    {
        var globalDeclaration = $"extern \"C\" __global__ void {entryPoint}(";
        var deviceDeclaration = $"__device__ void {entryPoint}_dispatch(";
        var declarationCount = CountOccurrences(source, globalDeclaration);
        if (declarationCount != 2)
        {
            throw new InvalidOperationException(
                $"CUDA entry point '{entryPoint}' requires one prototype and one definition. " +
                $"Actual declaration count={declarationCount}.");
        }

        var deviceSource = source.Replace(globalDeclaration, deviceDeclaration, StringComparison.Ordinal);
        return entryPoint == "mathblocks_scalar"
            ? deviceSource.Replace("blockIdx.x != 0 || ", string.Empty, StringComparison.Ordinal)
            : deviceSource.Replace("blockIdx.x != 0", "false", StringComparison.Ordinal);
    }

    private static int CountOccurrences(string source, string value)
    {
        var count = 0;
        var index = 0;
        while ((index = source.IndexOf(value, index, StringComparison.Ordinal)) >= 0)
        {
            count++;
            index += value.Length;
        }

        return count;
    }

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
                        builder.Append("\\u").Append(((int)character).ToString("X4"));
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

    private sealed record Unit(string Name, string SourcePath, string EntryPoint);

    private sealed record GeneratorOptions(
        string SourceRoot,
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
                Required(values, "--source-root"),
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
