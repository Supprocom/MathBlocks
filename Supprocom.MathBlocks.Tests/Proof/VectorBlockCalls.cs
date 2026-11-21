using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>The calls of the proof, their input arrays and the row counts. The file has no test-framework dependency; the 0.6.1 baseline console links it.</summary>
internal static class VectorBlockCalls
{
    /// <summary>The window form of standardize.</summary>
    internal const string Standardize = "window.vector.standardize@1";

    /// <summary>The scale identity.</summary>
    internal const string Scale = "vector.scale@1";

    /// <summary>The subtract identity.</summary>
    internal const string Subtract = "vector.subtract@1";

    /// <summary>The whole-vector route name.</summary>
    internal const string Whole = "whole";

    /// <summary>The lifted route name.</summary>
    internal const string Lifted = "lifted";

    /// <summary>The fill of an elementwise twin and of a window form (GenericOperationBinding.Fill, the grammar's zero fill slot).</summary>
    internal const float Fill = 0f;

    /// <summary>The device row counts of the timing and of the long parity runs.</summary>
    internal static readonly int[] TimingRows = [262_144, 1_048_576];

    /// <summary>The long parity row count.</summary>
    internal const int ParityRows = 262_144;

    // Search.Grammar.KernelWindows defaults to 3, 5, 8, 13, 21, 34, 55, 89 and accepts 2 to 256 (ResearchGrammarKernelLimits.WindowCeiling); the host grammar's Windows default to 2 through 96
    // (ResearchGrammarSpaceOptions.Windows). The sample is the smallest width, the smallest default, two defaults between, the host maximum and the widest the kernel accepts.
    internal static readonly int[] Windows = [2, 3, 21, 89, 96, 256];

    // The tuples of the two vector.scale grammar entries (ResearchGrammarCatalog): 0.5, 2 and 10 (positive), -1 and -2 (negative).
    internal static readonly float[] Factors = [0.5f, 2f, 10f, -1f, -2f];

    /// <summary>Builds every call of the proof; the lifted routes are left out for the 0.6.1 baseline, which has no elementwise twins.</summary>
    internal static List<VectorBlockCall> All(bool includeLifted)
    {
        var calls = new List<VectorBlockCall>();
        calls.Add(new VectorBlockCall(Subtract, Whole, "-", 1f, 0f, [Subtract], 1));
        if (includeLifted)
            calls.Add(new VectorBlockCall(Subtract, Lifted, "-", 1f, 0f, ["elementwise.scalar.subtract@1", "elementwise-valid.scalar.subtract@1"], 2));
        for (var index = 0; index < Factors.Length; index++)
        {
            var label = string.Create(CultureInfo.InvariantCulture, $"k={Factors[index]:R}");
            calls.Add(new VectorBlockCall(Scale, Whole, label, 1f, Factors[index], [Scale], 1));
            if (includeLifted)
                calls.Add(new VectorBlockCall(Scale, Lifted, label, 1f, Factors[index], ["elementwise.scalar.multiply@1", "elementwise-valid.scalar.multiply@1"], 2));
        }

        for (var index = 0; index < Windows.Length; index++)
        {
            var label = string.Create(CultureInfo.InvariantCulture, $"w={Windows[index]}");
            calls.Add(new VectorBlockCall(Standardize, Whole, label, Windows[index], 0f, [Standardize, "window-valid.vector.standardize@1"], 1));
        }

        return calls;
    }

    /// <summary>Gets the short series the proof covers for a call: one row, one row fewer than the window, and the window itself; a vector operation gets 1, 7 and 33 rows.</summary>
    internal static int[] ShortRows(VectorBlockCall call)
    {
        if (!call.IsWindow)
            return [1, 7, 33];
        var width = (int)call.Width;
        return [.. new[] { 1, Math.Max(1, width - 1), width }.Distinct()];
    }

    /// <summary>
    /// Replaces every value that is not finite by zero, which is what the host does before the call (GenericCandidateBlockEvaluator.Value reads such a row as 0 and marks the row invalid, so
    /// the node's row is NaN). A MathBlocks vector never holds a value that is not finite.
    /// </summary>
    internal static float[] Clean(float[] values)
    {
        var cleaned = new float[values.Length];
        for (var row = 0; row < values.Length; row++)
            cleaned[row] = float.IsFinite(values[row]) ? values[row] : 0f;
        return cleaned;
    }

    /// <summary>Builds the inputs of one dispatch of a call from the cleaned operand rows.</summary>
    internal static MathBlockValue[] Inputs(VectorBlockCall call, int step, float[] first, float[] second)
    {
        var inputs = new List<MathBlockValue> { MathBlockValue.Vector(first, MathBlockUnit.Dimensionless) };
        var withFill = step == 0 && (call.IsLifted || call.IsWindow);
        if (call.IsWindow)
        {
            inputs.Add(MathBlockValue.Scalar(call.Width));
        }
        else if (string.Equals(call.Identity, Scale, StringComparison.Ordinal))
        {
            inputs.Add(MathBlockValue.Scalar(call.Constant));
        }
        else
        {
            inputs.Add(MathBlockValue.Vector(second, MathBlockUnit.Dimensionless));
        }

        if (withFill)
            inputs.Add(MathBlockValue.Scalar(Fill));
        return [.. inputs];
    }
}
