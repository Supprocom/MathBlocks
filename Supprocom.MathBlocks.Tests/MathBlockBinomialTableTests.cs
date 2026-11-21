using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the source-inspection tests of the binomial table: its size and layout, the library prelude that defines it and the generator's no-op accessors.
/// They need neither NVRTC nor a CUDA device.
/// </summary>
public sealed class MathBlockBinomialTableTests
{
    private const int LargestRow = 1023;
    private const string Memo = "mathblocks_probability_binomial_memo(";
    private const string Load = "static __device__ __forceinline__ float mathblocks_binomial_table_load(int index)";
    private const string Store = "static __device__ __forceinline__ void mathblocks_binomial_table_store(int index, float value)";

    // The offset of the entry of (n, k) in the table, as the memo function computes it: the rows below n hold n / 2 * ((n - 1) / 2) + n entries.
    private static int Offset(int n, int k) => (n / 2) * ((n - 1) / 2) + n + Math.Min(k, n - k);

    private static string GeneratedSource() =>
        (string)typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaGeneratedSource", throwOnError: true)!
            .GetField("Source")!.GetRawConstantValue()!;

    private static int Count(string text, string value)
    {
        var count = 0;
        var position = text.IndexOf(value, StringComparison.Ordinal);
        while (position >= 0)
        {
            count++;
            position = text.IndexOf(value, position + value.Length, StringComparison.Ordinal);
        }

        return count;
    }

    /// <summary>Verifies the table holds the symmetric half of every row up to 1023: n / 2 + 1 entries for row n, which is 262,656 doubles and 2,101,248 bytes.</summary>
    [Fact]
    public void TheTableHoldsTheSymmetricHalfOfEveryRowUpTo1023()
    {
        var entries = 0;
        for (var n = 0; n <= LargestRow; n++)
            entries += (n / 2) + 1;

        Assert.Equal(262_656, entries);
        Assert.Equal(MathBlockCudaDeviceModule.BinomialTableEntryCount, entries);
        Assert.Equal(1_050_624L, (long)entries * sizeof(float));
    }

    /// <summary>Verifies the offset formula gives every entry of the table once: each pair 0 &lt;= k &lt;= n &lt;= 1023 lands on the entry of its symmetric pair, and no entry is left over.</summary>
    [Fact]
    public void TheOffsetFormulaIsOneToOneOntoTheTable()
    {
        var owner = new int[MathBlockCudaDeviceModule.BinomialTableEntryCount];
        Array.Fill(owner, -1);
        for (var n = 0; n <= LargestRow; n++)
        {
            for (var k = 0; k <= n; k++)
            {
                var offset = Offset(n, k);
                Assert.InRange(offset, 0, owner.Length - 1);
                Assert.Equal(Offset(n, n - k), offset);
                var half = Math.Min(k, n - k);
                Assert.True(owner[offset] is -1 || owner[offset] == ((n << 16) | half), $"({n}, {k}) shares entry {offset}.");
                owner[offset] = (n << 16) | half;
            }
        }

        Assert.DoesNotContain(-1, owner);
        Assert.Equal(0, Offset(0, 0));
        Assert.Equal(MathBlockCudaDeviceModule.BinomialTableEntryCount - 1, Offset(LargestRow, LargestRow / 2));
    }

    /// <summary>Verifies the device source of the defaults and of configured options defines the table once, with its accessors, before the generated units.</summary>
    [Fact]
    public void TheDeviceSourceDefinesTheTableOnceBeforeTheUnits()
    {
        var table = $"__device__ float {MathBlockCudaDeviceModule.BinomialTableSymbol}[{MathBlockCudaDeviceModule.BinomialTableEntryCount}];";
        var sources = new[]
        {
            MathBlockCudaDeviceModule.Source,
            MathBlockCudaDeviceModule.GetSource(new MathBlockDomainOptions { MaximumStateCount = 8192, MaximumMatrixSize = 5000 })
        };

        for (var index = 0; index < sources.Length; index++)
        {
            var source = sources[index];
            Assert.Equal(1, Count(source, table));
            Assert.Equal(1, Count(source, Load + " { return " + MathBlockCudaDeviceModule.BinomialTableSymbol + "[index]; }"));
            Assert.Equal(1, Count(source, Store + " { " + MathBlockCudaDeviceModule.BinomialTableSymbol + "[index] = value; }"));
            var firstUse = source.IndexOf(Memo, StringComparison.Ordinal);
            Assert.True(source.IndexOf(table, StringComparison.Ordinal) < firstUse);
            Assert.True(source.IndexOf(Store, StringComparison.Ordinal) < firstUse);
        }
    }

    /// <summary>Verifies the generated source compiles on its own with accessors that make the memo evaluate every pair: a load that returns 0 and a store that does nothing, and no table.</summary>
    [Fact]
    public void TheGeneratedSourceDefinesNoOpAccessorsAndNoTable()
    {
        var generated = GeneratedSource();
        var guard = generated.IndexOf("#ifndef MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal);
        var end = generated.IndexOf("#endif", guard, StringComparison.Ordinal);
        Assert.True(guard >= 0 && end > guard);
        var defaults = generated[guard..end];

        Assert.Equal(1, Count(defaults, Load + " { return 0.0; }"));
        Assert.Equal(1, Count(defaults, Store + " {}"));
        Assert.DoesNotContain(MathBlockCudaDeviceModule.BinomialTableSymbol + "[", defaults, StringComparison.Ordinal);
        Assert.DoesNotContain(Memo, generated[..end], StringComparison.Ordinal);
    }
}
