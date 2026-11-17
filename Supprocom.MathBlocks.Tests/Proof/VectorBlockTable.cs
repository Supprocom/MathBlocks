using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>One measurement of the vector-block table: a call on one input class at one row count, in nanoseconds per row.</summary>
/// <param name="Call">The call.</param>
/// <param name="ClassName">The input class name.</param>
/// <param name="Rows">The row count.</param>
/// <param name="NanosecondsPerRow">The median time per row of seven launches, measured with CUDA events.</param>
internal sealed record VectorBlockCell(VectorBlockCall Call, string ClassName, int Rows, double NanosecondsPerRow);

/// <summary>
/// Measures the vector-block table the one way the test and the 0.6.1 baseline console share: the same calls, the same input classes and real columns, the same row counts and the same
/// timing method. The file has no test-framework dependency; the console links it unchanged.
/// </summary>
internal static class VectorBlockTable
{
    /// <summary>The header of the table file.</summary>
    internal const string Header = "identity\troute\tparameter\tclass\trows\tns_per_row";

    /// <summary>Measures every call on every class at every row count; <paramref name="log"/> receives one line per cell.</summary>
    internal static List<VectorBlockCell> Measure(IReadOnlyList<VectorBlockCall> calls, int[] rowCounts, Action<string> log)
    {
        using var device = new VectorBlockDevice();
        var cells = new List<VectorBlockCell>();
        for (var rowIndex = 0; rowIndex < rowCounts.Length; rowIndex++)
        {
            var rows = rowCounts[rowIndex];
            var sets = ProofSets.ForRows(rows, includeReal: true);
            for (var callIndex = 0; callIndex < calls.Count; callIndex++)
            {
                for (var setIndex = 0; setIndex < sets.Length; setIndex++)
                {
                    using var run = device.Prepare(calls[callIndex], VectorBlockCalls.Clean(sets[setIndex].First), VectorBlockCalls.Clean(sets[setIndex].Second));
                    var cell = new VectorBlockCell(calls[callIndex], sets[setIndex].Name, rows, run.NanosecondsPerRow(rows));
                    cells.Add(cell);
                    log(Line(cell));
                }
            }
        }

        return cells;
    }

    /// <summary>Renders the cells as tab-separated text, one row per cell.</summary>
    internal static string Render(List<VectorBlockCell> cells)
    {
        var text = new StringBuilder(Header).Append('\n');
        for (var index = 0; index < cells.Count; index++)
            text.Append(Line(cells[index])).Append('\n');
        return text.ToString();
    }

    private static string Line(VectorBlockCell cell) =>
        string.Create(CultureInfo.InvariantCulture, $"{cell.Call.Identity}\t{cell.Call.Route}\t{cell.Call.Parameter}\t{cell.ClassName}\t{cell.Rows}\t{cell.NanosecondsPerRow:F3}");
}
