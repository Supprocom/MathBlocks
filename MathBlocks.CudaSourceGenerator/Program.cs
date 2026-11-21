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
        new("Transport", "TransportModule.cs"),
        new("Window", "WindowModule.cs"),
        new("Elementwise", "ElementwiseModule.cs")
    ];

    // The per-row functions, as in MathBlockCudaDevicePrelude.RowFunctions of the library, which a test compares with this text.
#pragma warning disable MA0136
    private const string RowFunctions = """
// Per-row arithmetic for a consumer's fused kernel: mathblocks_row_<op> evaluates one row of the scalar operation with the dispatch's bits.
// Each returns whether the row is valid (every argument finite and the value finite), and writes the value, or fill when the row is invalid, to *result.
// No fused multiply-add, no flushing, no slot access and no synchronization.
// The generated units define mathblocks_square_root; it is declared here so the row function can call it.
__device__ float mathblocks_square_root(float value);
static __device__ __forceinline__ bool mathblocks_row_finish(bool valid, float value, float fill, float* result) { *result = valid ? value : fill; return valid; }

// The value of each operation on its arguments, as the dispatch computes it: the dispatch and the row functions both call these.
// a + b, rounded to nearest
static __device__ __forceinline__ float mathblocks_row_value_add(float a, float b) { return __fadd_rn(a, b); }
// a - b, rounded to nearest
static __device__ __forceinline__ float mathblocks_row_value_subtract(float a, float b) { return __fsub_rn(a, b); }
// a * b, rounded to nearest
static __device__ __forceinline__ float mathblocks_row_value_multiply(float a, float b) { return __fmul_rn(a, b); }
// a / b, rounded to nearest
static __device__ __forceinline__ float mathblocks_row_value_divide(float a, float b) { return __fdiv_rn(a, b); }
// |a|
static __device__ __forceinline__ float mathblocks_row_value_absolute(float a) { return fabsf(a); }

// The row functions. Valid when the arguments and the value are finite.
// a + b; invalid when the sum overflows
static __device__ __forceinline__ bool mathblocks_row_add(float a, float b, float fill, float* result)
{
    float value = mathblocks_row_value_add(a, b);
    return mathblocks_row_finish(isfinite(a) && isfinite(b) && isfinite(value), value, fill, result);
}
// a - b; invalid when the difference overflows
static __device__ __forceinline__ bool mathblocks_row_subtract(float a, float b, float fill, float* result)
{
    float value = mathblocks_row_value_subtract(a, b);
    return mathblocks_row_finish(isfinite(a) && isfinite(b) && isfinite(value), value, fill, result);
}
// a * b; invalid when the product overflows
static __device__ __forceinline__ bool mathblocks_row_multiply(float a, float b, float fill, float* result)
{
    float value = mathblocks_row_value_multiply(a, b);
    return mathblocks_row_finish(isfinite(a) && isfinite(b) && isfinite(value), value, fill, result);
}
// a / b; invalid when b is 0.0f or the quotient overflows
static __device__ __forceinline__ bool mathblocks_row_divide(float a, float b, float fill, float* result)
{
    float value = mathblocks_row_value_divide(a, b);
    return mathblocks_row_finish(isfinite(a) && isfinite(b) && isfinite(value), value, fill, result);
}
// |a|
static __device__ __forceinline__ bool mathblocks_row_absolute(float a, float fill, float* result)
{
    float value = mathblocks_row_value_absolute(a);
    return mathblocks_row_finish(isfinite(a) && isfinite(value), value, fill, result);
}
// the square root of a; invalid when a is negative
static __device__ __forceinline__ bool mathblocks_row_square_root(float a, float fill, float* result)
{
    float value = mathblocks_square_root(a);
    return mathblocks_row_finish(isfinite(a) && isfinite(value), value, fill, result);
}
// The sum of values[0..count) added left to right from 0.0f with mathblocks_row_add's rule; stops at the first invalid step and gives false with fill. A count of 0 gives 0.0.
static __device__ __forceinline__ bool mathblocks_row_sum(const float* values, int count, float fill, float* result)
{
    float sum = 0.0f;
    for (int index = 0; index < count; index++)
    {
        if (!mathblocks_row_add(sum, values[index], fill, &sum))
            return mathblocks_row_finish(false, 0.0f, fill, result);
    }
    return mathblocks_row_finish(true, sum, fill, result);
}
""";
#pragma warning restore MA0136

    private static readonly string DomainPreludeDefaults =
        "// The default domain limits, no-op non-convergence recorders and no-op binomial table accessors (a load that returns 0, so the loop evaluates every pair), so the generated source compiles on its own. A source built for domain\n// options (MathBlockCudaDeviceModule.GetSource) starts with its own definitions and the macro below, which skips this block.\n#ifndef MATHBLOCKS_DOMAIN_PRELUDE\nstatic __device__ __forceinline__ int mathblocks_limit_explicit_subset_size() { return 20; }\nstatic __device__ __forceinline__ int mathblocks_limit_state_count() { return 4096; }\nstatic __device__ __forceinline__ int mathblocks_limit_generated_vector_length() { return 1000000; }\nstatic __device__ __forceinline__ int mathblocks_limit_submodular_set_function_values() { return 4096; }\nstatic __device__ __forceinline__ int mathblocks_limit_shapley_coalition_values() { return 1048576; }\nstatic __device__ __forceinline__ int mathblocks_limit_choquet_player_count() { return 30; }\nstatic __device__ __forceinline__ int mathblocks_limit_maximal_minor_columns() { return 20; }\nstatic __device__ __forceinline__ int mathblocks_limit_totally_nonnegative_size() { return 8; }\nstatic __device__ __forceinline__ int mathblocks_limit_matrix_size() { return 4096; }\nstatic __device__ __forceinline__ int mathblocks_limit_iteration_count() { return 10000; }\nstatic __device__ __forceinline__ int mathblocks_limit_incomplete_beta_maximum_iterations() { return 256; }\nstatic __device__ __forceinline__ float mathblocks_limit_incomplete_beta_tolerance() { return 2E-06f; }\nstatic __device__ __forceinline__ int mathblocks_limit_incomplete_beta_policy() { return 0; }\nstatic __device__ __forceinline__ int mathblocks_limit_matrix_exponential_taylor_terms() { return 48; }\nstatic __device__ __forceinline__ int mathblocks_limit_cube_root_newton_steps() { return 3; }\nstatic __device__ __forceinline__ int mathblocks_limit_jacobi_policy() { return 0; }\nstatic __device__ __forceinline__ long long mathblocks_limit_jacobi_rotation_budget(int size) { return (long long)64 * size * size; }\nstatic __device__ __forceinline__ int mathblocks_limit_elementwise_source_count() { return 53; }\n__device__ unsigned long long mathblocks_nonconvergence_counts[1];\nstatic __device__ __forceinline__ float mathblocks_binomial_table_load(int index) { return 0.0f; }\nstatic __device__ __forceinline__ void mathblocks_binomial_table_store(int index, float value) {}\nstatic __device__ void mathblocks_nonconvergence_record_probability(int opcode) {}\nstatic __device__ void mathblocks_nonconvergence_record_elementwise(int opcode) {}\nstatic __device__ void mathblocks_nonconvergence_record_matrix(int opcode) {}\nstatic __device__ void mathblocks_nonconvergence_record_graph(int opcode) {}\n" + RowFunctions.ReplaceLineEndings("\n") + "\n#endif\n\n";

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
        var fullSource = DomainPreludeDefaults + string.Concat(GenerateUnits(options, transpilationOptions)) + "\n" +
                         GenerateDispatch(options, transpilationOptions);
        var fullBytes = Encoding.UTF8.GetBytes(fullSource);
        var fullHash = Convert.ToHexString(SHA256.HashData(fullBytes));
        const string expectedFullHash =
            "06880895A73E35387D7AFD8CB98F104FE72FCA84A49EB3D30A451095A9617117";
        if (!string.Equals(fullHash, expectedFullHash, StringComparison.Ordinal))
            throw new InvalidOperationException(
                $"Full CUDA source hash mismatch. Expected {expectedFullHash}, actual {fullHash}.");

        Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedCuda)!);
        File.WriteAllBytes(options.GeneratedCuda, fullBytes);
        Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedSource)!);
        File.WriteAllText(options.GeneratedSource, CreateGeneratedSource(fullBytes), new UTF8Encoding(false));
        WriteProtocolLine($"source-bytes={fullBytes.Length}");
        WriteProtocolLine($"source-sha256={fullHash}");
        if (!string.IsNullOrEmpty(options.GeneratedTypeRuleSource))
            GenerateTypeRules(options, transpilationOptions);
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
        WriteUnitEvidence(options.EvidenceRoot, "DeviceDispatch", source);
        AssertExact("DeviceDispatch", source, NormalizeLineEndings(golden));
        WriteProtocolLine($"unit=DeviceDispatch bytes={Encoding.UTF8.GetByteCount(source)} " +
                          $"sha256={Hash(source)} exact=True diagnostics=0");
        return source;
    }

    // The type-rule module is a separate CUDA source with its own golden, so the full-source hash above, the device
    // ABI fingerprint and the operation table do not move with it. Its translation unit is also compiled into
    // Supprocom.MathBlocks, where the host resolver calls it.
    private static void GenerateTypeRules(GeneratorOptions options, CudaTranspilationOptions transpilationOptions)
    {
        var result = CudaTranspiler.TranspileFiles(
            [Path.Combine(options.TranslationRoot, "TypeRuleUnit.cs"), Path.Combine(options.TranslationRoot, "TypeRuleDeviceUnit.cs")],
            options: transpilationOptions);
        if (!result.Succeeded)
            throw new InvalidOperationException(
                $"Type-rule CUDA translation failed: {string.Join(Environment.NewLine, result.Diagnostics)}");
        var source = NormalizeLineEndings(result.Source);
        WriteUnitEvidence(options.EvidenceRoot, new Unit("TypeRule", "TypeRuleUnit.cs"), source);
        var golden = File.ReadAllText(Path.Combine(options.GoldenRoot, "TypeRuleCudaBlockCatalog.cu"), Encoding.UTF8);
        WriteUnitEvidence(options.EvidenceRoot, "TypeRule", source);
        AssertExact("TypeRule", source, NormalizeLineEndings(golden));
        var sourceBytes = Encoding.UTF8.GetBytes(source);
        Directory.CreateDirectory(Path.GetDirectoryName(options.GeneratedTypeRuleSource)!);
        File.WriteAllText(
            options.GeneratedTypeRuleSource,
            CreateGeneratedSource(sourceBytes, "MathBlockCudaTypeRuleGeneratedSource"),
            new UTF8Encoding(false));
        WriteProtocolLine($"unit=TypeRule bytes={sourceBytes.Length} sha256={Hash(sourceBytes)} exact=True diagnostics=0");
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

    private static string CreateGeneratedSource(byte[] source, string className = "MathBlockCudaGeneratedSource")
    {
        var text = Encoding.UTF8.GetString(source);
        var builder = new StringBuilder();
        builder.AppendLine("// <auto-generated/>");
        builder.AppendLine("namespace Supprocom.MathBlocks.Cuda;");
        builder.AppendLine();
        builder.Append("internal static class ").AppendLine(className);
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

    private static void WriteUnitEvidence(string evidenceRoot, Unit unit, string source) => WriteUnitEvidence(evidenceRoot, unit.Name, source);

    private static void WriteUnitEvidence(string evidenceRoot, string unitName, string source)
    {
        if (string.IsNullOrEmpty(evidenceRoot))
            return;

        Directory.CreateDirectory(evidenceRoot);
        var path = Path.Combine(evidenceRoot, $"{unitName}.cu");
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
        string EvidenceRoot,
        string GeneratedTypeRuleSource);

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
                values.GetValueOrDefault("--evidence-root", string.Empty),
                values.GetValueOrDefault("--generated-type-rule-source", string.Empty));
        }

        private static string Required(Dictionary<string, string> values, string name) =>
            values.TryGetValue(name, out var value) && !string.IsNullOrWhiteSpace(value)
                ? value
                : throw new ArgumentException($"Missing required argument '{name}'.");
    }
}
