namespace Supprocom.MathBlocks.Tests;

/// <summary>Owns the loaded consumer modules of the dispatch test class and unloads them when the class ends.</summary>
public sealed class MathBlockCudaDispatchModuleFixture : IDisposable
{
    internal MathBlockCudaTestModuleCache Modules { get; } = new(module =>
    {
        MathBlockCudaWorkerTestsBaseOpcodeDispatch.CudaDriver.Initialize();
        _ = MathBlockCudaWorkerTestsBaseOpcodeDispatch.CudaDriver.cuModuleUnload(module);
    });

    /// <inheritdoc />
    public void Dispose() => Modules.Dispose();
}
