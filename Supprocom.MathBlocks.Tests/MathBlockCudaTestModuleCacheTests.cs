namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the key of the device test module cache without a device.</summary>
public sealed class MathBlockCudaTestModuleCacheTests
{
    private static readonly string[] Options = ["architecture=compute_80", "--fmad=false", "--prec-div=true", "--prec-sqrt=true"];
    private const string Consumer = "extern \"C\" __global__ void k() {}";

    /// <summary>Verifies the same inputs give the same key.</summary>
    [Fact]
    public void TheSameInputsGiveTheSameKey() =>
        Assert.Equal(
            MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", MathBlockDomainOptions.Default, Options),
            MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", new MathBlockDomainOptions(), [.. Options]),
            StringComparer.Ordinal);

    /// <summary>Verifies a different consumer source, domain options, source name or compile option gives a different key.</summary>
    [Fact]
    public void ADifferentSourceDomainOptionsOrCompileOptionGivesADifferentKey()
    {
        var baseKey = MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", MathBlockDomainOptions.Default, Options);
        var keys = new[]
        {
            MathBlockCudaTestModuleCache.Key(Consumer + " ", "a.cu", MathBlockDomainOptions.Default, Options),
            MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", new MathBlockDomainOptions { MaximumStateCount = 8192 }, Options),
            MathBlockCudaTestModuleCache.Key(Consumer, "b.cu", MathBlockDomainOptions.Default, Options),
            MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", MathBlockDomainOptions.Default, [Options[0], "--fmad=true", Options[2], Options[3]]),
            MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", MathBlockDomainOptions.Default, ["architecture=compute_90", .. Options[1..]]),
            MathBlockCudaTestModuleCache.Key(Consumer, "a.cu", MathBlockDomainOptions.Default, Options[..3])
        };

        Assert.DoesNotContain(baseKey, keys, StringComparer.Ordinal);
        Assert.Equal(keys.Length, keys.Distinct(StringComparer.Ordinal).Count());
    }

    /// <summary>Verifies the field boundaries are part of the key.</summary>
    [Fact]
    public void MovingTextAcrossAFieldBoundaryChangesTheKey() =>
        Assert.NotEqual(
            MathBlockCudaTestModuleCache.Key("ab", "c", ["x"]),
            MathBlockCudaTestModuleCache.Key("a", "bc", ["x"]),
            StringComparer.Ordinal);

    /// <summary>Verifies a module loads once per key and every module unloads at dispose.</summary>
    [Fact]
    public void AModuleLoadsOncePerKeyAndUnloadsAtDispose()
    {
        var unloaded = new List<IntPtr>();
        var loads = 0;
        var cache = new MathBlockCudaTestModuleCache(unloaded.Add);
        (IntPtr, IntPtr) Load()
        {
            loads++;
            return ((IntPtr)(100 + loads), (IntPtr)1);
        }

        var first = cache.GetOrLoad("a", Load);
        Assert.Equal(first, cache.GetOrLoad("a", Load));
        _ = cache.GetOrLoad("b", Load);
        Assert.Equal(2, loads);
        cache.Dispose();
        Assert.Equal(2, unloaded.Count);
        Assert.Throws<ObjectDisposedException>(() => cache.GetOrLoad("a", Load));
    }
}
