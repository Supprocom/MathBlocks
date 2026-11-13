using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies without a device that the generated elementwise dispatcher derives the argument kinds from the input slots.</summary>
public sealed class MathBlockElementwiseDispatchSourceTests
{
    /// <summary>Verifies the device source derives the mask, uses it when the opcode carries none, and rejects a slot the passed mask leaves clear.</summary>
    [Fact]
    public void ElementwiseDispatcherDerivesTheMaskFromTheInputSlots()
    {
        var source = MathBlockCudaDeviceModule.Source;
        var start = source.IndexOf("mathblocks_elementwise_run(", StringComparison.Ordinal);
        Assert.True(start >= 0, "The elementwise run function is missing.");
        var body = source[start..];
        var end = body.IndexOf("mathblocks_elementwise_publish(output, valid", StringComparison.Ordinal);
        Assert.True(end > 0, "The publish call is missing.");
        body = body[..end];

        Assert.Contains("int passed_mask = csharp2cuda_i32_div(opcode, 128);", body, StringComparison.Ordinal);
        Assert.Contains("int derived_mask = 0;", body, StringComparison.Ordinal);
        Assert.Contains("((passed_mask) == (0))", body, StringComparison.Ordinal);
        Assert.Contains("(csharp2cuda_i32_and(derived_mask, csharp2cuda_i32_not(mask))) == (0)", body, StringComparison.Ordinal);
    }

    /// <summary>Verifies the public elementwise opcodes carry no mask bits, so a consumer dispatches them with the base opcode.</summary>
    [Fact]
    public void PublicElementwiseOpcodesAreBaseOpcodes()
    {
        var elementwise = MathBlockCudaDeviceModule.Operations.Where(contract => contract.Family == MathBlockCudaOperationFamily.Elementwise).ToArray();
        Assert.Equal(106, elementwise.Length);
        Assert.All(elementwise, contract => Assert.InRange(contract.Opcode, 0, 127));
    }
}
