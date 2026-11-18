using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// Loads a few days of real market columns for the real-data class: the first two daily files of the cbtf-binance-btc-1s-v1 frames of 2024-12, 60,000 rows each
/// at most. Only rows dated 2018 to 2024 are used; the first row dated later ends the file without being used. The file paths, the date range and the SHA-256
/// of the accepted rows are written to the report folder, and nothing is copied into the repository. Without the data the class is skipped with a message.
/// </summary>
internal static class ProofRealData
{
    private const string SourceFolder = "/home/claude/data/cbtf/frames-1s";
    private const string FilePattern = "CBTF-1s-2024-*.jsonl";
    private const string TimeMarker = "\"OpenTimeUtc\":\"";
    private const int FileCount = 2;
    private const int RowsPerFile = 60_000;
    private const int FirstAllowedYear = 2018;
    private const int LastAllowedYear = 2024;

    private static readonly byte[] LineFeed = [10];
    private static readonly Lazy<Columns?> Loaded = new(Load);

    /// <summary>Gets why the real-data class is absent, or an empty string when it is present.</summary>
    internal static string SkipReason { get; private set; } = string.Empty;

    /// <summary>Gets the real columns, or null when the data is missing.</summary>
    internal static Columns? Get() => Loaded.Value;

    private static Columns? Load()
    {
        if (!Directory.Exists(SourceFolder))
        {
            SkipReason = $"The real market data folder {SourceFolder} does not exist.";
            return null;
        }

        var files = Directory.GetFiles(SourceFolder, FilePattern);
        Array.Sort(files, StringComparer.Ordinal);
        var rows = new Accumulator();
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        var used = new List<string>();
        for (var index = 0; index < files.Length && index < FileCount; index++)
        {
            used.Add(files[index]);
            ReadFile(files[index], rows, hash);
        }

        if (rows.Close.Count == 0)
        {
            SkipReason = string.Create(CultureInfo.InvariantCulture, $"No real market rows dated {FirstAllowedYear} to {LastAllowedYear} were found in {SourceFolder}.");
            return null;
        }

        var sha = Convert.ToHexString(hash.GetHashAndReset());
        var note = string.Create(
            CultureInfo.InvariantCulture,
            $"files: {string.Join(", ", used)}\nrows: {rows.Close.Count}\nvalues: {rows.Close.Count * 3}\nfirst OpenTimeUtc: {rows.First}\nlast OpenTimeUtc: {rows.Last}\nsha256 of the accepted lines, each followed by LF: {sha}\n");
        _ = ProofReport.WriteText("real-data.txt", note);
        return new Columns([.. rows.Close], [.. rows.Volume], [.. rows.Trades]);
    }

    private static void ReadFile(string path, Accumulator rows, IncrementalHash hash)
    {
        using var reader = new StreamReader(path, Encoding.UTF8);
        var taken = 0;
        while (taken < RowsPerFile && reader.ReadLine() is { } line)
        {
            var year = YearOf(line);
            if (year < FirstAllowedYear || year > LastAllowedYear)
                return;
            if (!TryAdd(line, rows))
                continue;
            hash.AppendData(Encoding.UTF8.GetBytes(line));
            hash.AppendData(LineFeed);
            taken++;
        }
    }

    // The year of the row's open time, read from the text before the row is parsed; zero when the row has no open time.
    private static int YearOf(string line)
    {
        var start = line.IndexOf(TimeMarker, StringComparison.Ordinal);
        if (start < 0 || line.Length < start + TimeMarker.Length + 4)
            return 0;
        var digits = line.AsSpan(start + TimeMarker.Length, 4);
        return int.TryParse(digits, NumberStyles.None, CultureInfo.InvariantCulture, out var year) ? year : 0;
    }

    private static bool TryAdd(string line, Accumulator rows)
    {
        using var document = JsonDocument.Parse(line);
        var root = document.RootElement;
        if (!TryNumber(root, "UsdtSpotClosePrice", out var close) ||
            !TryNumber(root, "UsdtSpotBaseVolume", out var volume) ||
            !TryNumber(root, "UsdtSpotTradeCount", out var trades) ||
            !root.TryGetProperty("OpenTimeUtc", out var opened))
        {
            return false;
        }

        var stamp = opened.GetString() ?? string.Empty;
        if (rows.Close.Count == 0)
            rows.First = stamp;
        rows.Last = stamp;
        rows.Close.Add(close);
        rows.Volume.Add(volume);
        rows.Trades.Add(trades);
        return true;
    }

    private static bool TryNumber(JsonElement root, string name, out double value)
    {
        value = 0d;
        return root.TryGetProperty(name, out var element) && element.ValueKind == JsonValueKind.Number && element.TryGetDouble(out value) && double.IsFinite(value);
    }

    /// <summary>The real close prices, base volumes and trade counts, one entry per accepted row.</summary>
    /// <param name="close">The USDT spot close prices.</param>
    /// <param name="volume">The USDT spot base volumes.</param>
    /// <param name="trades">The USDT spot trade counts.</param>
    internal sealed class Columns(double[] close, double[] volume, double[] trades)
    {
        /// <summary>Gets the close prices.</summary>
        internal double[] Close { get; } = close;

        /// <summary>Gets the base volumes.</summary>
        internal double[] Volume { get; } = volume;

        /// <summary>Gets the trade counts.</summary>
        internal double[] Trades { get; } = trades;
    }

    private sealed class Accumulator
    {
        internal List<double> Close { get; } = [];

        internal List<double> Volume { get; } = [];

        internal List<double> Trades { get; } = [];

        internal string First { get; set; } = string.Empty;

        internal string Last { get; set; } = string.Empty;
    }
}
