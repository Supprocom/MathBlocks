namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks that the odd and sign-preserving scalar operations keep the sign of zero, as IEEE 754 does.</summary>
public sealed class MathBlockSignedZeroTests
{
    /// <summary>Gets the scalar operations for which IEEE 754 and every libm give f(+0) = +0 and f(-0) = -0.</summary>
    public static TheoryData<string> SignPreservingOperations =>
    [
        "scalar.sine",
        "scalar.tangent",
        "scalar.arc-sine",
        "scalar.arc-tangent",
        "scalar.hyperbolic-sine",
        "scalar.hyperbolic-tangent",
        "scalar.inverse-hyperbolic-sine",
        "scalar.inverse-hyperbolic-tangent",
        "scalar.cube-root",
        "special.error-function",
        "scalar.log-one-plus",
        "scalar.square-root",
        "scalar.cube",
        "scalar.truncate",
        "scalar.floor",
        "scalar.ceiling",
        "scalar.round"
    ];

    /// <summary>Verifies the operation maps +0 to +0 and -0 to -0, bit for bit.</summary>
    [Theory]
    [MemberData(nameof(SignPreservingOperations))]
    public void OperationKeepsTheSignOfZero(string identifier)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var unit = operation.RegressionCases[0].Inputs[0].Type.Unit;
        foreach (var zero in new[] { 0d, -0d })
        {
            var result = operation.Evaluate([MathBlockValue.Scalar(zero, unit)]);
            Assert.True(result.IsValid, $"{identifier}({zero:R}) is invalid.");
            Assert.True(
                BitConverter.DoubleToInt64Bits(result.AsScalar()) == BitConverter.DoubleToInt64Bits(zero),
                $"{identifier}(0x{BitConverter.DoubleToInt64Bits(zero):X16}) gave " +
                $"0x{BitConverter.DoubleToInt64Bits(result.AsScalar()):X16}.");
        }
    }

    /// <summary>Verifies arc-tangent-2 at a zero ordinate gives the IEEE 754 and C99 Annex F results.</summary>
    [Theory]
    [InlineData("+0", "1", "+0")]
    [InlineData("-0", "1", "-0")]
    [InlineData("+0", "+0", "+0")]
    [InlineData("-0", "+0", "-0")]
    [InlineData("+0", "-1", "pi")]
    [InlineData("-0", "-1", "-pi")]
    [InlineData("+0", "-0", "pi")]
    [InlineData("-0", "-0", "-pi")]
    public void ArcTangent2KeepsTheSignOfAZeroOrdinate(string yText, string xText, string expectedText)
    {
        var (y, x, expected) = (Parse(yText), Parse(xText), Parse(expectedText));
        var operation = MathBlockCatalog.Standard.Get("scalar.arc-tangent-2");
        var inputs = operation.RegressionCases[0].Inputs;
        var result = operation.Evaluate(
            [MathBlockValue.Scalar(y, inputs[0].Type.Unit), MathBlockValue.Scalar(x, inputs[1].Type.Unit)]);
        Assert.True(result.IsValid);
        Assert.True(
            BitConverter.DoubleToInt64Bits(result.AsScalar()) == BitConverter.DoubleToInt64Bits(expected),
            $"atan2(0x{BitConverter.DoubleToInt64Bits(y):X16}, 0x{BitConverter.DoubleToInt64Bits(x):X16}) gave " +
            $"0x{BitConverter.DoubleToInt64Bits(result.AsScalar()):X16}, expected 0x{BitConverter.DoubleToInt64Bits(expected):X16}.");
    }

    /// <summary>Verifies the complex phase on the real axis follows C99 Annex G carg, including the sign of zero.</summary>
    [Theory]
    [InlineData("-1", "-0", "-pi")]
    [InlineData("-1", "+0", "pi")]
    [InlineData("1", "-0", "-0")]
    [InlineData("1", "+0", "+0")]
    public void ComplexPhaseFollowsAnnexGOnTheRealAxis(string realText, string imaginaryText, string expectedText)
    {
        var (real, imaginary, expected) = (Parse(realText), Parse(imaginaryText), Parse(expectedText));
        var operation = MathBlockCatalog.Standard.Get("complex.phase");
        var result = operation.Evaluate([ComplexInput(operation, real, imaginary)]);
        Assert.True(result.IsValid);
        AssertBits(expected, result.AsScalar(), $"carg({real:R}, 0x{BitConverter.DoubleToInt64Bits(imaginary):X16})");
    }

    /// <summary>Verifies the complex logarithm on the negative real axis follows C99 Annex G clog.</summary>
    [Theory]
    [InlineData("-1", "-0", "+0", "-pi")]
    [InlineData("-1", "+0", "+0", "pi")]
    public void ComplexLogarithmFollowsAnnexGOnTheNegativeRealAxis(
        string realText, string imaginaryText, string expectedRealText, string expectedImaginaryText)
    {
        var (real, imaginary) = (Parse(realText), Parse(imaginaryText));
        var (expectedReal, expectedImaginary) = (Parse(expectedRealText), Parse(expectedImaginaryText));
        var operation = MathBlockCatalog.Standard.Get("complex.natural-logarithm");
        var result = operation.Evaluate([ComplexInput(operation, real, imaginary)]);
        Assert.True(result.IsValid);
        var label = $"clog({real:R}, 0x{BitConverter.DoubleToInt64Bits(imaginary):X16})";
        AssertBits(expectedReal, result.AsComplex().Real, label + " real");
        AssertBits(expectedImaginary, result.AsComplex().Imaginary, label + " imaginary");
    }

    /// <summary>Verifies the complex square root on the negative real axis follows C99 Annex G csqrt.</summary>
    [Theory]
    [InlineData("-1", "-0", "+0", "-1")]
    [InlineData("-1", "+0", "+0", "1")]
    public void ComplexSquareRootFollowsAnnexGOnTheNegativeRealAxis(
        string realText, string imaginaryText, string expectedRealText, string expectedImaginaryText)
    {
        var (real, imaginary) = (Parse(realText), Parse(imaginaryText));
        var (expectedReal, expectedImaginary) = (Parse(expectedRealText), Parse(expectedImaginaryText));
        var operation = MathBlockCatalog.Standard.Get("complex.square-root");
        var result = operation.Evaluate([ComplexInput(operation, real, imaginary)]);
        Assert.True(result.IsValid);
        var label = $"csqrt({real:R}, 0x{BitConverter.DoubleToInt64Bits(imaginary):X16})";
        AssertBits(expectedReal, result.AsComplex().Real, label + " real");
        AssertBits(expectedImaginary, result.AsComplex().Imaginary, label + " imaginary");
    }

    private static MathBlockValue ComplexInput(MathBlockOperation operation, double real, double imaginary) =>
        MathBlockValue.Complex(new Complex(real, imaginary), operation.RegressionCases[0].Inputs[0].Type.Unit);

    private static void AssertBits(double expected, double actual, string label) =>
        Assert.True(
            BitConverter.DoubleToInt64Bits(actual) == BitConverter.DoubleToInt64Bits(expected),
            $"{label} gave 0x{BitConverter.DoubleToInt64Bits(actual):X16}, expected 0x{BitConverter.DoubleToInt64Bits(expected):X16}.");

    // InlineData cannot hold both zeros (xUnit treats 0d and -0d as duplicates), so cases use text.
    private static double Parse(string text) => text switch
    {
        "+0" => 0d,
        "-0" => -0d,
        "pi" => Math.PI,
        "-pi" => -Math.PI,
        _ => double.Parse(text, System.Globalization.CultureInfo.InvariantCulture)
    };
}
