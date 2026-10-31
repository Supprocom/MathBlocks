using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

// Shared helpers for the M2 fast-window tests. The direct lift of the window forms stays reachable through the
// internal WindowMathBlocks.DirectReference registry, reached by reflection like the Windowed registry.
internal static class MathBlockWindowM2TestSupport
{
    private static readonly Lazy<MathBlockRegistry> directReference = new(() => (MathBlockRegistry)typeof(MathBlockCatalog)
        .Assembly
        .GetType("Supprocom.MathBlocks.WindowMathBlocks", throwOnError: true)!
        .GetProperty("DirectReference", BindingFlags.NonPublic | BindingFlags.Static)!
        .GetValue(null)!);

    // The M1 sources whose window forms have an M2 kernel.
    public static readonly string[] KernelSources =
    [
        "vector.minimum", "vector.maximum", "vector.arg-minimum", "vector.arg-maximum", "vector.median", "vector.quantile"
    ];

    // The six window-accurate.* names.
    public static readonly string[] AccurateNames =
    [
        "sum", "mean", "population-variance", "sample-variance", "population-standard-deviation",
        "sample-standard-deviation"
    ];

    public static MathBlockRegistry DirectReference => directReference.Value;

    public static MathBlockOperation DirectForm(string source) => DirectReference.Get($"window.{source}");

    public static MathBlockOperation DirectValidity(string source) => DirectReference.Get($"window-valid.{source}");

    public static MathBlockOperation AccurateForm(string name) => MathBlockWindowTestSupport.Windowed.Get($"window-accurate.{name}");

    public static MathBlockOperation AccurateValidity(string name) =>
        MathBlockWindowTestSupport.Windowed.Get($"window-accurate-valid.{name}");

    // Describes the first difference between two values: type, invalid state and reason, then row bits.
    public static string? Difference(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.Type != actual.Type)
            return $"type {actual.Type}, expected {expected.Type}";
        if (expected.IsValid != actual.IsValid)
            return $"valid {actual.IsValid}, expected {expected.IsValid} ({expected.InvalidReason ?? actual.InvalidReason})";
        if (!expected.IsValid)
        {
            return string.Equals(expected.InvalidReason, actual.InvalidReason, StringComparison.Ordinal)
                ? null
                : $"reason '{actual.InvalidReason}', expected '{expected.InvalidReason}'";
        }
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            var left = expected.AsBooleanVector().ToArray();
            var right = actual.AsBooleanVector().ToArray();
            for (var row = 0; row < left.Length; row++)
                if (left[row] != right[row])
                    return $"row {row}: {right[row]}, expected {left[row]}";
            return null;
        }
        var values = expected.AsVector().ToArray();
        var others = actual.AsVector().ToArray();
        for (var row = 0; row < values.Length; row++)
        {
            if (BitConverter.DoubleToInt64Bits(values[row]) != BitConverter.DoubleToInt64Bits(others[row]))
            {
                return string.Create(
                    System.Globalization.CultureInfo.InvariantCulture,
                    $"row {row}: {others[row]:R} (bits {BitConverter.DoubleToInt64Bits(others[row]):X16}), expected {values[row]:R} (bits {BitConverter.DoubleToInt64Bits(values[row]):X16})");
            }
        }
        return null;
    }
}
