using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks the generated CUDA source of a fused expression without a CUDA device.</summary>
public sealed class MathBlockFusedExpressionSourceTests
{
    /// <summary>The source of a program that uses every fused operation equals its golden text.</summary>
    [Fact]
    [Trait("Category", "CudaSourceContract")]
    public void CUDASourceOfEveryOperationEqualsItsGoldenText()
    {
        var fused = MathBlockFusedExpression.Create(CreateGoldenProgram());
        var actual = Normalize(fused);
        var path = Path.Combine(AppContext.BaseDirectory, "Golden", "MathBlockFusedExpression.cu");
        var expected = File.ReadAllText(path).Replace("\r\n", "\n", StringComparison.Ordinal);
        if (!string.Equals(expected, actual, StringComparison.Ordinal))
        {
            File.WriteAllText(Path.Combine(AppContext.BaseDirectory, "MathBlockFusedExpression.actual.cu"), actual);
            Assert.Fail("The fused CUDA source differs from Golden/MathBlockFusedExpression.cu; the actual text is " +
                        "next to the test assembly as MathBlockFusedExpression.actual.cu.");
        }
    }

    /// <summary>Inline arithmetic uses rounding intrinsics and each operation calls its dispatcher's device function.</summary>
    [Fact]
    [Trait("Category", "CudaSourceContract")]
    public void CUDASourceUsesRoundingIntrinsicsAndTheDispatcherDeviceFunctions()
    {
        var fused = MathBlockFusedExpression.Create(CreateGoldenProgram());
        var source = fused.CudaSource;
        foreach (var intrinsic in new[]
                 {
                     "__dadd_rn(", "__dsub_rn(", "__dmul_rn(", "__ddiv_rn(", "mathblocks_exponential(",
                     "mathblocks_natural_logarithm(", "mathblocks_square_root(", "mathblocks_power(",
                     "mathblocks_maximum(", "mathblocks_complex_make(", "mathblocks_complex_magnitude(", "fabs(",
                     "atomicOr(invalid_mask, invalid)"
                 })
            Assert.Contains(intrinsic, source, StringComparison.Ordinal);
        var body = source[source.IndexOf("__device__ void", StringComparison.Ordinal)..];
        foreach (var line in body.Split('\n'))
        {
            if (line.TrimStart().StartsWith("//", StringComparison.Ordinal) || !line.Contains(" = ", StringComparison.Ordinal))
                continue;
            var expression = line[(line.IndexOf(" = ", StringComparison.Ordinal) + 3)..];
            foreach (var plain in new[] { " + ", " - ", " * ", " / " })
                Assert.False(
                    expression.Contains(plain, StringComparison.Ordinal) && !line.Contains("blockIdx", StringComparison.Ordinal),
                    $"Plain floating-point arithmetic in: {line}");
        }
        foreach (var row in new[]
                 {
                     "const int k34 = isfinite(n32) && isfinite(n3) && mathblocks_elementwise_row_value(" +
                     "mathblocks_elementwise_source_opcode(8), n32, n3, 0.0, &v34);",
                     "const double n34 = k34 ? v34 : n33;",
                     "const int r34 = r32 & k34;",
                     "mathblocks_elementwise_source_opcode(3), n34, 0.0, 0.0, &v35);",
                     "mathblocks_elementwise_source_opcode(12), n35, n4, n1, &v36);",
                     "const int r36 = r35 & r1 & k36;",
                     "const int b37 = k37;",
                     "const int r37 = r0 & r1;"
                 })
            Assert.Contains(row, source, StringComparison.Ordinal);
        var elementwise = body[body.IndexOf("// node 34", StringComparison.Ordinal)..body.IndexOf("// node 38", StringComparison.Ordinal)];
        Assert.DoesNotContain("invalid |= 0x", elementwise, StringComparison.Ordinal);
        Assert.Contains($"__device__ void {fused.CudaFunctionName}(", source, StringComparison.Ordinal);
        Assert.Contains($"extern \"C\" __global__ void {fused.CudaKernelName}(", source, StringComparison.Ordinal);
        Assert.Equal(source, MathBlockFusedExpression.Create(CreateGoldenProgram()).CudaSource);
    }

    // Replaces the fingerprints with placeholders, so the golden text survives changes to the MathBlocks CUDA source.
    internal static string Normalize(MathBlockFusedExpression fused) => fused.CudaSource
        .Replace(fused.Fingerprint, "<fused-fingerprint>", StringComparison.Ordinal)
        .Replace(fused.Program.Fingerprint, "<program-fingerprint>", StringComparison.Ordinal)
        .Replace(MathBlockCudaDeviceModule.SourceFingerprint, "<source-fingerprint>", StringComparison.Ordinal);

    internal static MathBlockProgram CreateGoldenProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockFusedTestSupport.WithElementwise.Value);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var mask = builder.Input("mask", MathBlockType.BooleanVector());
        var exponent = builder.Input("exponent", MathBlockType.Scalar());
        var half = builder.Constant(MathBlockValue.Scalar(-0.5));
        var sum = builder.Apply("vector.add", 1, x, y);
        var difference = builder.Apply("vector.subtract", 1, x, y);
        var product = builder.Apply("vector.multiply", 1, sum, difference);
        var quotient = builder.Apply("vector.divide", 1, product, y);
        var shifted = builder.Apply("vector.add-scalar", 1, quotient, half);
        var scaled = builder.Apply("vector.scale", 1, shifted, half);
        var absolute = builder.Apply("vector.absolute", 1, scaled);
        var sign = builder.Apply("vector.sign", 1, difference);
        var positive = builder.Apply("vector.positive-part", 1, difference);
        var square = builder.Apply("vector.square", 1, positive);
        var root = builder.Apply("vector.square-root", 1, absolute);
        var exponential = builder.Apply("vector.exponential", 1, sign);
        var logarithm = builder.Apply("vector.natural-logarithm", 1, exponential);
        var power = builder.Apply("vector.power", 1, root, exponent);
        var equal = builder.Apply("vector.equal", 1, x, y);
        var less = builder.Apply("vector.less-than", 1, square, power);
        var greater = builder.Apply("vector.greater-than", 1, logarithm, x);
        var both = builder.Apply("boolean-vector.and", 1, less, mask);
        var either = builder.Apply("boolean-vector.or", 1, equal, greater);
        var one = builder.Apply("boolean-vector.xor", 1, both, either);
        var not = builder.Apply("boolean-vector.not", 1, one);
        var selected = builder.Apply("vector.select", 1, not, power, square);
        var complex = builder.Apply("complex-vector.create", 1, selected, x);
        var real = builder.Apply("complex-vector.real", 1, complex);
        var imaginary = builder.Apply("complex-vector.imaginary", 1, complex);
        var magnitude = builder.Apply("complex-vector.magnitude", 1, complex);
        var total = builder.Apply("vector.add", 1, builder.Apply("vector.add", 1, real, imaginary), magnitude);

        // Elementwise forms of both CUDA per-row functions (Scalar and Probability), with broadcast scalars in
        // the second and third masks, a form of a form, and a sibling.
        var fill = builder.Constant(MathBlockValue.Scalar(-1d));
        var angle = builder.Apply("elementwise.scalar.arc-tangent-2", 1, total, exponent, fill);
        var cdf = builder.Apply("elementwise.probability.normal-cdf", 1, angle, fill);
        var clamped = builder.Apply("elementwise.scalar.clamp", 1, cdf, half, y, fill);
        var computed = builder.Apply("elementwise-valid.special.beta", 1, x, y);
        var final = builder.Apply("vector.add", 1, total, clamped);
        var flag = builder.Apply("boolean-vector.and", 1, not, computed);
        return builder.Output("total", final).Output("flag", flag).Output("y", y).Output("power", power).Build();
    }
}
