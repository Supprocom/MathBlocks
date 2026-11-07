using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks without a device that the module's PTX holds none of the instructions that could change a result's bits.</summary>
public sealed partial class MathBlockPtxAllowListTests
{
    private const string Architecture = "compute_86";

    private static readonly (string Name, Regex Pattern)[] Forbidden =
    [
        (".approx", Approximate()),
        (".ftz", FlushToZero()),
        ("float atom or red", FloatAtomic()),
        ("mma or wmma", TensorCore()),
        ("call to __nv_ or __internal_", LibdeviceCall())
    ];

    [GeneratedRegex(@"^\s*(?:\.visible\s+|\.weak\s+)?\.(?:entry|func)\s+(?:\([^)]*\)\s*)?(?<name>[\w$.]+)", RegexOptions.CultureInvariant | RegexOptions.ExplicitCapture, 5000)]
    private static partial Regex EntryOrFunction();

    [GeneratedRegex(@"\.approx\b", RegexOptions.CultureInvariant, 5000)]
    private static partial Regex Approximate();

    [GeneratedRegex(@"\.ftz\b", RegexOptions.CultureInvariant, 5000)]
    private static partial Regex FlushToZero();

    [GeneratedRegex(@"^\s*(?:@!?%p\d+\s+)?(?:atom|red)\b[^;]*\.(?:f16x2|f16|bf16x2|bf16|f32|f64)\b", RegexOptions.CultureInvariant, 5000)]
    private static partial Regex FloatAtomic();

    [GeneratedRegex(@"^\s*(?:@!?%p\d+\s+)?(?:wmma|mma)\.", RegexOptions.CultureInvariant, 5000)]
    private static partial Regex TensorCore();

    [GeneratedRegex(@"\bcall(?:\.uni)?\s*(?:\([^)]*\)\s*,\s*)?(?:__nv_|__internal_)\w*", RegexOptions.CultureInvariant, 5000)]
    private static partial Regex LibdeviceCall();

    /// <summary>Verifies the whole module compiled for compute_86 under --fmad=false has no forbidden instruction.</summary>
    [Fact]
    [Trait("Category", "PtxAllowList")]
    public void ModulePtxHasNoApproximateFlushingTensorOrLibdeviceInstruction()
    {
        var compile = typeof(MathBlockCatalog).Assembly
            .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
            .GetMethod(
                "CompilePtxWithoutDevice",
                BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
                [typeof(string), typeof(string), typeof(string)])!;
        var bytes = (byte[])compile.Invoke(null, [MathBlockCudaDeviceModule.Source, "mathblocks.cu", Architecture])!;
        var ptx = Encoding.UTF8.GetString(bytes).TrimEnd('\0');
        Assert.Contains(".entry", ptx, StringComparison.Ordinal);

        var findings = Scan(ptx);
        Assert.True(findings.Count == 0, string.Join(Environment.NewLine, findings));
    }

    /// <summary>Verifies the scan flags each forbidden form, names the function and keeps integer atoms.</summary>
    [Fact]
    [Trait("Category", "PtxAllowList")]
    public void ScanFlagsEachForbiddenFormAndAllowsIntegerAtoms()
    {
        var ptx = string.Join(
            "\n",
            ".visible .entry first(",
            ")",
            "{",
            "    sqrt.approx.f32 %f1, %f2;",
            "    add.ftz.f32 %f1, %f2, %f3;",
            "    atom.global.add.f64 %fd1, [%rd1], %fd2;",
            "    red.global.add.f32 [%rd1], %f2;",
            "    atom.global.exch.b32 %r1, [%rd1], %r2;",
            "    atom.global.add.u32 %r1, [%rd1], %r2;",
            "    mma.sync.aligned.m16n8k8.row.col.f32.tf32.tf32.f32 {%f1}, {%r1}, {%r2}, {%f2};",
            "    wmma.mma.sync.aligned.row.col.m16n16k16.f32.f32 {%f1}, {%r1}, {%r2}, {%f2};",
            "    call.uni (retval0), __nv_sin, (param0);",
            "    call.uni (retval0), mathblocks_helper, (param0);",
            "}",
            ".func (.param .b64 r) helper()",
            "{",
            "    call (retval0), __internal_trig_reduction_slowpathd, (param0);",
            "}");
        var findings = Scan(ptx);
        Assert.Equal(6, findings.Count);
        Assert.Contains(findings, f => f.Contains(".approx", StringComparison.Ordinal) && f.Contains("first", StringComparison.Ordinal));
        Assert.Contains(findings, f => f.Contains("float atom or red", StringComparison.Ordinal) && f.Contains("atom.global.add.f64", StringComparison.Ordinal));
        Assert.Contains(findings, f => f.Contains("helper", StringComparison.Ordinal) && f.Contains("__internal_", StringComparison.Ordinal));
        Assert.DoesNotContain(findings, f => f.Contains("exch.b32", StringComparison.Ordinal) || f.Contains("add.u32", StringComparison.Ordinal));
    }

    private static List<string> Scan(string ptx)
    {
        var findings = new List<string>();
        var seen = new HashSet<(string, string)>();
        var current = "(outside any function)";
        foreach (var raw in ptx.Split('\n'))
        {
            var line = raw.TrimEnd('\r');
            var comment = line.IndexOf("//", StringComparison.Ordinal);
            var code = comment >= 0 ? line[..comment] : line;
            var header = EntryOrFunction().Match(code);
            if (header.Success)
                current = header.Groups["name"].Value;
            foreach (var (name, pattern) in Forbidden)
            {
                if (pattern.IsMatch(code) && seen.Add((name, current)))
                    findings.Add($"{name} in {current}: {code.Trim()}");
            }
        }

        return findings;
    }
}
