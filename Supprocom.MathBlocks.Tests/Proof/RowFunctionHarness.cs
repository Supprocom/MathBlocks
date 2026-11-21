namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Runs the parity and row-sum kernels on a fixed number of rows: it owns the device buffers and downloads what each launch wrote.</summary>
internal sealed class RowFunctionHarness : IDisposable
{
    /// <summary>The fill that every row function is given.</summary>
    internal const float Fill = -98_765.25f;

    /// <summary>The largest number of values per row that <see cref="RunSum"/> accepts.</summary>
    internal const int MaximumSumCount = 33;

    private readonly ProofDeviceSession session;
    private readonly int rows;
    private readonly ulong first;
    private readonly ulong second;
    private readonly ulong sumValues;
    private readonly ulong rowValues;
    private readonly ulong rowValid;
    private readonly ulong narrowValues;
    private readonly ulong narrowValid;
    private readonly ulong wideValues;
    private readonly ulong wideValid;

    /// <summary>Compiles the kernels and allocates the buffers for the given number of rows.</summary>
    internal RowFunctionHarness(int rows)
    {
        this.rows = rows;
        session = new ProofDeviceSession(RowFunctionKernels.Source(), "proof-row-functions.cu");
        first = session.Allocate(rows * (long)sizeof(float));
        second = session.Allocate(rows * (long)sizeof(float));
        sumValues = session.Allocate(rows * (long)MaximumSumCount * sizeof(float));
        rowValues = session.Allocate(rows * (long)sizeof(float));
        rowValid = session.Allocate(rows * (long)sizeof(int));
        narrowValues = session.Allocate(rows * (long)sizeof(float));
        narrowValid = session.Allocate(rows * (long)sizeof(int));
        wideValues = session.Allocate(rows * (long)sizeof(float));
        wideValid = session.Allocate(rows * (long)sizeof(int));
    }

    /// <summary>Runs one row function and the elementwise row function for its source, in both encodings, over the operands.</summary>
    internal ParityResult Run(RowFunctionOp function, float[] a, float[] b)
    {
        ProofDeviceSession.Upload(first, a);
        ProofDeviceSession.Upload(second, b);
        var kernel = session.Function("proof_parity_" + function.Name);
        var arguments = session.Arguments(rows, Fill, function.Source, first, second, rowValues, rowValid, narrowValues, narrowValid, wideValues, wideValid);
        ProofDeviceSession.Launch(kernel, arguments, rows);
        ProofDeviceSession.Synchronize();
        return new ParityResult(
            ProofDeviceSession.DownloadBits(rowValues, rows),
            ProofDeviceSession.DownloadInts(rowValid, rows),
            ProofDeviceSession.DownloadBits(narrowValues, rows),
            ProofDeviceSession.DownloadInts(narrowValid, rows),
            ProofDeviceSession.DownloadBits(wideValues, rows),
            ProofDeviceSession.DownloadInts(wideValid, rows));
    }

    /// <summary>Runs the row sum over <paramref name="count"/> consecutive values per row and returns the bits and the validity of each row.</summary>
    internal (long[] Bits, int[] Valid) RunSum(float[] values, int count)
    {
        ProofDeviceSession.Upload(sumValues, values);
        var kernel = session.Function("proof_row_sum");
        var arguments = session.Arguments(rows, count, Fill, sumValues, rowValues, rowValid);
        ProofDeviceSession.Launch(kernel, arguments, rows);
        ProofDeviceSession.Synchronize();
        return (ProofDeviceSession.DownloadBits(rowValues, rows), ProofDeviceSession.DownloadInts(rowValid, rows));
    }

    /// <summary>Releases the device buffers and the module.</summary>
    public void Dispose() => session.Dispose();
}
