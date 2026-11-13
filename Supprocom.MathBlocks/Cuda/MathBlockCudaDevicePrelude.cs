using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

// The device source text that comes before the generated units: one function per domain limit, which the units call, and the
// non-convergence counters. A MathBlockDomainOptions value becomes the return value of its function, so the generated units are the
// same text at every option value and only this prelude differs.
internal static class MathBlockCudaDevicePrelude
{
    // The operations whose evaluations can end without converging, by the family dispatcher that records them.
    private static readonly (string Suffix, MathBlockCudaFamily Family, string[] Identities)[] Recorders =
    [
        ("probability", MathBlockCudaFamily.Probability, ["special.regularized-incomplete-beta@1"]),
        (
            "elementwise",
            MathBlockCudaFamily.Elementwise,
            [
                "elementwise.special.regularized-incomplete-beta@1",
                "elementwise-valid.special.regularized-incomplete-beta@1"
            ]),
        (
            "matrix",
            MathBlockCudaFamily.Matrix,
            [
                "matrix.symmetric-eigenvalues@1",
                "matrix.largest-symmetric-eigenvalue@1",
                "matrix.smallest-symmetric-eigenvalue@1",
                "matrix.spectral-norm@1"
            ]),
        ("graph", MathBlockCudaFamily.Graph, ["graph.algebraic-connectivity@1"])
    ];

    // The identities that have a counter slot; the counters are indexed by position in MathBlockCudaDeviceModule.Operations.
    internal static IEnumerable<string> CountedIdentities
    {
        get
        {
            foreach (var recorder in Recorders)
            {
                foreach (var identity in recorder.Identities)
                    yield return identity;
            }
        }
    }

    internal static string Create(MathBlockDomainOptions domain, IReadOnlyList<string> operations)
    {
        var text = new StringBuilder(4096);
        text.Append("// MathBlocks domain limits and non-convergence counters.\n");
        Limit(text, "explicit_subset_size", domain.MaximumExplicitSubsetSize);
        Limit(text, "state_count", domain.MaximumStateCount);
        Limit(text, "generated_vector_length", domain.MaximumGeneratedVectorLength);
        Limit(text, "submodular_set_function_values", domain.MaximumSubmodularSetFunctionValues);
        Limit(text, "shapley_coalition_values", domain.MaximumShapleyCoalitionValues);
        Limit(text, "choquet_player_count", domain.MaximumChoquetPlayerCount);
        Limit(text, "maximal_minor_columns", domain.MaximumMaximalMinorColumns);
        Limit(text, "totally_nonnegative_size", domain.MaximumTotallyNonnegativeSize);
        Limit(text, "matrix_size", domain.MaximumMatrixSize);
        Limit(text, "iteration_count", domain.MaximumIterationCount);
        Limit(text, "incomplete_beta_maximum_iterations", domain.IncompleteBetaMaximumIterations);
        text.Append("static __device__ __forceinline__ double mathblocks_limit_incomplete_beta_tolerance() { return ")
            .Append(DoubleLiteral(domain.IncompleteBetaTolerance)).Append("; }\n");
        Limit(text, "incomplete_beta_policy", (int)domain.IncompleteBetaNonConvergence);
        Limit(text, "matrix_exponential_taylor_terms", domain.MatrixExponentialTaylorTerms);
        Limit(text, "cube_root_newton_steps", domain.CubeRootNewtonSteps);
        Limit(text, "jacobi_policy", (int)domain.JacobiNonConvergence);
        text.Append("static __device__ __forceinline__ long long mathblocks_limit_jacobi_rotation_budget(int size) { return (long long)")
            .Append(domain.JacobiRotationMultiplier.ToString(CultureInfo.InvariantCulture))
            .Append(" * size * size; }\n");
        Limit(text, "elementwise_source_count", ElementwiseMathBlocks.SourceCount);
        text.Append("__device__ unsigned long long ").Append(MathBlockCudaDeviceModule.NonConvergenceCountsSymbol).Append('[')
            .Append(Math.Max(1, operations.Count).ToString(CultureInfo.InvariantCulture)).Append("];\n");
        text.Append("static __device__ __forceinline__ void mathblocks_nonconvergence_add(int slot) { atomicAdd(&")
            .Append(MathBlockCudaDeviceModule.NonConvergenceCountsSymbol).Append("[slot], 1ull); }\n");
        foreach (var (suffix, family, identities) in Recorders)
            AppendRecorder(text, suffix, family, identities, operations);
        text.Append('\n');
        return text.ToString();
    }

    private static void Limit(StringBuilder text, string name, int value) =>
        text.Append("static __device__ __forceinline__ int mathblocks_limit_").Append(name).Append("() { return ")
            .Append(value.ToString(CultureInfo.InvariantCulture)).Append("; }\n");

    private static void AppendRecorder(
        StringBuilder text,
        string suffix,
        MathBlockCudaFamily family,
        string[] identities,
        IReadOnlyList<string> operations)
    {
        text.Append("static __device__ void mathblocks_nonconvergence_record_").Append(suffix).Append("(int opcode)\n{\n    switch (opcode)\n    {\n");
        foreach (var identity in identities)
        {
            var index = IndexOf(operations, identity);
            var feature = MathBlockCudaFeatureIndex.Resolve(identity);
            if (feature.Family != family)
                throw new InvalidOperationException($"CUDA operation '{identity}' is not in the {family} family.");
            text.Append("        case ").Append(feature.Opcode.ToString(CultureInfo.InvariantCulture))
                .Append(": mathblocks_nonconvergence_add(").Append(index.ToString(CultureInfo.InvariantCulture)).Append("); break;\n");
        }

        text.Append("        default: break;\n    }\n}\n");
    }

    private static int IndexOf(IReadOnlyList<string> operations, string identity)
    {
        for (var index = 0; index < operations.Count; index++)
        {
            if (string.Equals(operations[index], identity, StringComparison.Ordinal))
                return index;
        }

        throw new InvalidOperationException($"CUDA operation '{identity}' is not registered.");
    }

    // A C++ double literal that reads back as the same double.
    private static string DoubleLiteral(double value)
    {
        var text = value.ToString("R", CultureInfo.InvariantCulture);
        return text.AsSpan().IndexOfAny('.', 'E') < 0 ? text + ".0" : text;
    }
}
