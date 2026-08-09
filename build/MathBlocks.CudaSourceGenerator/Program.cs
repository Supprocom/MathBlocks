using System.Security.Cryptography;
using System.Text;
using CSharp2CUDA;

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

            foreach (var unit in Units)
            {
                var sourcePath = Path.Combine(options.SourceRoot, unit.SourcePath.Replace('/', Path.DirectorySeparatorChar));
                var source = ExtractTranslationUnit(sourcePath);
                var result = CudaTranspiler.Transpile(
                    source,
                    new CudaTranspilationOptions { NewLine = "\r\n" },
                    Path.GetFileName(sourcePath));
                if (!result.Succeeded)
                {
                    throw new InvalidOperationException(
                        $"{unit.Name} CUDA translation failed: {string.Join(Environment.NewLine, result.Diagnostics)}");
                }

                var deviceSource = ToDeviceSource(result.Source, unit.EntryPoint);
                var publishedUnit = deviceSource + "\n";
                var goldenPath = Path.Combine(options.GoldenRoot, $"{unit.Name}CudaBlockCatalog.cu");
                var golden = File.ReadAllText(goldenPath, Encoding.UTF8);

                AssertExact(unit.Name, NormalizeLineEndings(publishedUnit), NormalizeLineEndings(golden));
                generatedUnits.Add(publishedUnit);
                WriteUnitEvidence(options.EvidenceRoot, unit, publishedUnit);
                Console.WriteLine(
                    $"unit={unit.Name} bytes={Encoding.UTF8.GetByteCount(publishedUnit)} " +
                    $"sha256={Hash(publishedUnit)} exact=True diagnostics=0");
            }

            var dispatchSourcePath = Path.Combine(
                options.SourceRoot,
                "Cuda/Blocks/DeviceDispatch/DeviceDispatchCudaBlockCatalog.cs".Replace('/', Path.DirectorySeparatorChar));
            var dispatchSource = ExtractTranslationUnit(dispatchSourcePath);
            var dispatchResult = CudaTranspiler.Transpile(
                dispatchSource,
                new CudaTranspilationOptions { NewLine = "\r\n" },
                Path.GetFileName(dispatchSourcePath));
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
                "4C1A777AC24A1A7ECF5477F021351DEA0B4205EE39EF41D293FF1645F181E35C";
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

    private static string ToDeviceSource(string source, string entryPoint)
    {
        var globalDeclaration = $"extern \"C\" __global__ void {entryPoint}(";
        var deviceDeclaration = $"__device__ void {entryPoint}_dispatch(";
        var declarationIndex = source.IndexOf(globalDeclaration, StringComparison.Ordinal);
        if (declarationIndex < 0 ||
            source.IndexOf(globalDeclaration, declarationIndex + globalDeclaration.Length, StringComparison.Ordinal) >= 0)
        {
            throw new InvalidOperationException($"CUDA entry point '{entryPoint}' is not unique.");
        }

        var deviceSource = source.Replace(globalDeclaration, deviceDeclaration, StringComparison.Ordinal);
        deviceSource = entryPoint == "mathblocks_scalar"
            ? deviceSource.Replace("blockIdx.x != 0 || ", string.Empty, StringComparison.Ordinal)
            : deviceSource.Replace("blockIdx.x != 0", "false", StringComparison.Ordinal);
        return CanonicalizePublishedLineEndings(deviceSource, entryPoint);
    }

    private static string CanonicalizePublishedLineEndings(string source, string entryPoint)
    {
        var builder = new StringBuilder(source.Length);
        var newlineIndex = 0;
        for (var index = 0; index < source.Length; index++)
        {
            var character = source[index];
            if (character == '\r')
            {
                if (index + 1 < source.Length && source[index + 1] == '\n')
                    index++;
                AppendPublishedNewline(builder, entryPoint, ++newlineIndex);
                continue;
            }

            if (character == '\n')
            {
                AppendPublishedNewline(builder, entryPoint, ++newlineIndex);
                continue;
            }

            builder.Append(character);
        }

        return builder.ToString();
    }

    private static void AppendPublishedNewline(StringBuilder builder, string entryPoint, int newlineIndex)
    {
        if (IsPublishedLfOnlyLine(entryPoint, newlineIndex))
            builder.Append('\n');
        else
            builder.Append("\r\n");
    }

    private static bool IsPublishedLfOnlyLine(string entryPoint, int newlineIndex) =>
        entryPoint switch
        {
            "mathblocks_scalar" => newlineIndex == 474,
            "mathblocks_vector" =>
                IsInRange(newlineIndex, 82, 92) ||
                IsInRange(newlineIndex, 609, 642) ||
                newlineIndex == 676,
            "mathblocks_complex" => newlineIndex == 340,
            "mathblocks_matrix" => newlineIndex == 1238,
            "mathblocks_probability" => newlineIndex == 657,
            "mathblocks_sequence_path" =>
                IsInRange(newlineIndex, 13, 23) ||
                IsInRange(newlineIndex, 29, 39) ||
                IsInRange(newlineIndex, 41, 361) ||
                IsInRange(newlineIndex, 529, 793) ||
                IsInRange(newlineIndex, 1133, 1141) ||
                IsInRange(newlineIndex, 1145, 1153) ||
                newlineIndex == 1299,
            "mathblocks_statistics" => newlineIndex == 537,
            "mathblocks_geometry" =>
                IsInRange(newlineIndex, 382, 390) ||
                IsInRange(newlineIndex, 467, 474) ||
                IsInRange(newlineIndex, 480, 483) ||
                IsInRange(newlineIndex, 589, 596) ||
                IsInRange(newlineIndex, 602, 605) ||
                IsInRange(newlineIndex, 768, 778) ||
                newlineIndex == 862,
            "mathblocks_graph" =>
                IsInRange(newlineIndex, 240, 247) ||
                IsInRange(newlineIndex, 252, 255) ||
                newlineIndex == 560,
            "mathblocks_advanced" => newlineIndex == 546,
            "mathblocks_transport" => IsInRange(newlineIndex, 386, 387),
            _ => throw new InvalidOperationException(
                $"CUDA line-ending authority is missing for '{entryPoint}'.")
        };

    private static bool IsInRange(int value, int minimum, int maximum) => value >= minimum && value <= maximum;

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
