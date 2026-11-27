using System.Globalization;
using System.Reflection;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The parts of the logic-block proof that need no device: every block has a device contract, the grid of the device parity test evaluates on CoreCLR with both valid and invalid
/// results, a scalar that is not finite makes the comparison invalid, and a kernel that dispatches every block through the device source compiles with NVRTC.
/// </summary>
public sealed class LogicBlockContractTests
{
    private const string Architecture = "compute_86";

    private static readonly MethodInfo Compile = typeof(MathBlockCatalog).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
        .GetMethod(
            "CompilePtxWithoutDevice",
            BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
            [typeof(string), typeof(string), typeof(string), typeof(bool)])!;

    /// <summary>Verifies every logic block has a device contract and a catalog entry, and that greater-or-equal, less-or-equal and not-equal exist as scalar blocks.</summary>
    [Fact]
    public void EveryLogicBlockHasAContractAndACatalogEntry()
    {
        Assert.Equal(25, LogicBlocks.All.Length);
        for (var index = 0; index < LogicBlocks.All.Length; index++)
        {
            var identity = LogicBlocks.All[index];
            Assert.Equal(identity, MathBlockCudaDeviceModule.GetOperation(identity).Identity);
            Assert.True(LogicBlocks.Arity(identity) > 0, identity);
        }
    }

    /// <summary>Verifies the cases of the device parity test give valid and invalid results on CoreCLR for every block, and that a scalar comparison of NaN or an infinity is invalid.</summary>
    [Fact]
    public void TheParityCasesCoverValidAndInvalidResultsOnCoreCLR()
    {
        for (var index = 0; index < LogicBlocks.All.Length; index++)
        {
            var identity = LogicBlocks.All[index];
            var contract = MathBlockCudaDeviceModule.GetOperation(identity);
            var cases = LogicBlocks.ParityCases(identity);
            var valid = cases.Count(inputs => contract.EvaluateCoreCLR(inputs).IsValid);
            Assert.True(valid > 0 && valid < cases.Count, identity);
        }

        var greater = MathBlockCudaDeviceModule.GetOperation("scalar.greater-than@1");
        Assert.False(greater.EvaluateCoreCLR(MathBlockValue.Scalar(float.NaN), MathBlockValue.Scalar(1f)).IsValid);
        Assert.False(greater.EvaluateCoreCLR(MathBlockValue.Scalar(1f), MathBlockValue.Scalar(float.PositiveInfinity)).IsValid);
        Assert.True(greater.EvaluateCoreCLR(MathBlockValue.Scalar(1f), MathBlockValue.Scalar(-1f)).AsBoolean());
    }

    /// <summary>Verifies a kernel that dispatches every logic block by its family and opcode compiles with NVRTC after the device source, without a CUDA device.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void AKernelThatDispatchesEveryLogicBlockCompilesWithNVRTC()
    {
        var kernel = new StringBuilder(
            "extern \"C\" __global__ void logic_dispatch(MathBlockSlot* slots)\n{\n    const MathBlockSlot* inputs[4] = { &slots[0], &slots[1], &slots[2], &slots[3] };\n");
        for (var index = 0; index < LogicBlocks.All.Length; index++)
        {
            var contract = MathBlockCudaDeviceModule.GetOperation(LogicBlocks.All[index]);
            kernel.Append(CultureInfo.InvariantCulture, $"    mathblocks_operation_dispatch({(int)contract.Family}, {contract.Opcode}, inputs, {LogicBlocks.Arity(LogicBlocks.All[index])}, &slots[4]);\n");
        }

        kernel.Append("}\n");
        var composed = MathBlockCudaDeviceModule.ComposeSource(kernel.ToString(), MathBlockDomainOptions.Default);
        string ptx;
        try
        {
            ptx = Encoding.UTF8.GetString((byte[])Compile.Invoke(null, [composed, "mathblocks-logic-consumer.cu", Architecture, false])!);
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw new InvalidOperationException(exception.InnerException.Message, exception.InnerException);
        }

        Assert.Contains(".entry logic_dispatch", ptx, StringComparison.Ordinal);
    }
}
