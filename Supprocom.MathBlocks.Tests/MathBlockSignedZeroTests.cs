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
}
