using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

// Builds the limit records of MathBlockLimits. Every record resolves against the given CUDA and domain options; a
// limit without an option reports today's constant.
internal static class MathBlockLimitCatalog
{
    private const string SpeedOnly = "speed-only; results unchanged";
    private const string CudaOptions = nameof(MathBlocksCudaOptions);
    private const string DomainOptions = nameof(MathBlockDomainOptions);
    private static readonly string[] NoDrivers = [];

    private sealed record DomainEntry(
        string Name,
        string Option,
        string Unit,
        long Minimum,
        long Maximum,
        Func<MathBlockDomainOptions, long> Read,
        string[] Operations,
        string Rule);

    internal static List<MathBlockLimit> Resolve(MathBlocksCudaOptions cuda, MathBlockDomainOptions domain)
    {
        MathBlockLimitSeam.ValidateCuda(cuda);
        domain.Validate();
        var limits = new List<MathBlockLimit>(320);
        AddCuda(limits, cuda);
        AddWindowWidths(limits, cuda);
        AddFused(limits, cuda);
        AddDomain(limits, domain);
        AddWindowAndSequenceRules(limits);
        AddDeviceModule(limits, cuda, domain);
        AddNotation(limits);
        AddFixed(limits);
        return limits;
    }

    internal static List<MathBlockLimit> For(
        string operationIdentity,
        MathBlocksCudaOptions cuda,
        MathBlockDomainOptions domain)
    {
        var all = Resolve(cuda, domain);
        var result = new List<MathBlockLimit>();
        foreach (ref readonly var limit in CollectionsMarshal.AsSpan(all))
        {
            if (limit.Operation is null || string.Equals(limit.Operation, operationIdentity, StringComparison.Ordinal))
                result.Add(limit);
        }

        return result;
    }

    private static void AddCuda(List<MathBlockLimit> limits, MathBlocksCudaOptions cuda)
    {
        limits.Add(new MathBlockLimit(
            "cuda.block-size", null, MathBlockLimitKind.Option, MathBlockLimitDevice.Cuda,
            1, MathBlockLimitSeam.MaximumThreadsPerBlock, cuda.BlockSize, "threads",
            $"{CudaOptions}.{nameof(MathBlocksCudaOptions.BlockSize)}", NoDrivers,
            "threads per block of every kernel launch except the fused-expression kernel and the scalar family; the CUDA limit is 1,024 threads per block"));
        limits.Add(new MathBlockLimit(
            "cuda.grid-x", null, MathBlockLimitKind.Launch, MathBlockLimitDevice.Cuda,
            1, int.MaxValue, cuda.MaximumGridX, "blocks",
            $"{CudaOptions}.{nameof(MathBlocksCudaOptions.MaximumGridX)}", NoDrivers, SpeedOnly));
        limits.Add(new MathBlockLimit(
            "cuda.window.scratch-budget-bytes", null, MathBlockLimitKind.Launch, MathBlockLimitDevice.Cuda,
            1, null, cuda.WindowScratchBudgetBytes, "bytes",
            $"{CudaOptions}.{nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes)}", NoDrivers, SpeedOnly));
        limits.Add(new MathBlockLimit(
            "cuda.device-ordinal", null, MathBlockLimitKind.Option, MathBlockLimitDevice.Cuda,
            0, null, MathBlockLimitSeam.DeviceOrdinal(cuda), "device",
            $"{CudaOptions}.DeviceOrdinal", NoDrivers,
            "the CUDA device that runs the programs; its compute capability sets the architecture string; the valid maximum is the device count"));
        AddSlotLayout(limits);
        AddAccumulator(limits);
        AddElementwiseLayout(limits);
    }

    private static void AddSlotLayout(List<MathBlockLimit> limits)
    {
        limits.Add(Fixed("cuda.slot.size-bytes", MathBlockLimitDevice.Cuda, MathBlockCudaSlotLayout.Size, "bytes",
            "one value slot is 48 bytes: scalar, data and scratch pointers, boolean, valid, rows, columns, count and capacity"));
        limits.Add(Fixed("cuda.slot.maximum-count", MathBlockLimitDevice.Cuda, int.MaxValue, "elements",
            "rows, columns, count and capacity of a slot are 32-bit ints, so no value holds more than 2,147,483,647 elements"));
        limits.Add(Fixed("cuda.run.size-bytes", MathBlockLimitDevice.Cuda, MathBlockCudaRunLayout.Size, "bytes",
            "one run descriptor is 16 bytes: start, length and value"));
        limits.Add(Fixed("cuda.graph-edge.size-bytes", MathBlockLimitDevice.Cuda, MathBlockCudaGraphEdgeLayout.Size, "bytes",
            "one graph edge descriptor is 16 bytes: from, to and weight"));
    }

    private static void AddAccumulator(List<MathBlockLimit> limits)
    {
        limits.Add(Fixed("cuda.window-accurate.accumulator-chunks", MathBlockLimitDevice.Cuda, 141, "words",
            "141 chunks of 32 bits count units of 2^(-2208 + 32 i), a range of 2^-2208 to 2^2304 that holds the exact sum of the squares of finite doubles (2^-2148 to 2^2048)"));
        limits.Add(Fixed("cuda.window-accurate.accumulator-words", MathBlockLimitDevice.Cuda, 285, "words",
            "285 = 141 chunks + 141 read-scratch chunks + 3 bookkeeping words (lowest and highest chunk touched, additions since the last carry)"));
        limits.Add(Fixed("cuda.window-accurate.variance-accumulator-words", MathBlockLimitDevice.Cuda, 570, "words",
            "the variance and deviation forms keep two accumulators of 285 words each, whatever the width"));
        limits.Add(Fixed("cuda.window-accurate.carry-flush-additions", MathBlockLimitDevice.Cuda, 1L << 27, "additions",
            "each addition puts a piece below 2^33 into a 64-bit chunk, so a carry flush every 2^27 additions keeps every chunk below 2^60 < 2^63"));
    }

    private static void AddElementwiseLayout(List<MathBlockLimit> limits)
    {
        limits.Add(Fixed("cuda.elementwise.value-element-bytes", MathBlockLimitDevice.Cuda, Cuda.MathBlockCudaDeviceModule.ElementwiseValueElementBytes, "bytes",
            "the values form elementwise.<source> writes a double per row at an 8-byte stride in data_pointer; a row that is not computed holds the fill"));
        limits.Add(Fixed("cuda.elementwise.validity-element-bytes", MathBlockLimitDevice.Cuda, Cuda.MathBlockCudaDeviceModule.ElementwiseValidityElementBytes, "bytes",
            "the validity form elementwise-valid.<source> writes an int32 0 or 1 per row at a 4-byte stride in data_pointer"));
        limits.Add(Fixed("cuda.elementwise.invalid-result-rows", MathBlockLimitDevice.Cuda, 0, "rows",
            "both forms set rows and count of the output slot to the row count, and to 0 when the whole result is invalid"));
        limits.Add(Fixed("cuda.elementwise.opcode-source-multiplier", MathBlockLimitDevice.Cuda, 2, "opcodes",
            "opcode = 2 * source + sibling, with sibling 1 for the validity form"));
        limits.Add(Fixed("cuda.elementwise.opcode-mask-multiplier", MathBlockLimitDevice.Cuda, 128, "opcodes",
            "a consumer may add 128 * mask, bit i marking argument i as a vector; without it the device derives the mask from the input slots"));
        limits.Add(Fixed("cuda.elementwise.fill-input", MathBlockLimitDevice.Cuda, null, "input index",
            "the fill of the values form is the last input, inputs[arity], a Scalar slot with the source result unit of which CUDA reads only scalar_value; the validity form has no fill input"));
    }

    // One record per window form: the largest width whose scratch for one block fits int byte offsets, which follows
    // from the block size.
    private static void AddWindowWidths(List<MathBlockLimit> limits, MathBlocksCudaOptions cuda)
    {
        foreach (var feature in WindowCudaBlockCatalog.Features)
        {
            var source = feature.Opcode / 2;
            var maximum = MaximumWindowWidth(source, cuda.BlockSize);
            if (maximum == int.MaxValue)
            {
                limits.Add(new MathBlockLimit(
                    "cuda.window.maximum-width", feature.Identity, MathBlockLimitKind.Fixed, MathBlockLimitDevice.Cuda,
                    1, int.MaxValue, int.MaxValue, "rows", null, NoDrivers,
                    "the scratch of this form does not depend on the width, which is an int"));
                continue;
            }

            limits.Add(new MathBlockLimit(
                "cuda.window.maximum-width", feature.Identity, MathBlockLimitKind.Derived, MathBlockLimitDevice.Cuda,
                1, maximum, maximum, "rows", null, ["cuda.block-size"],
                "the largest width whose scratch doubles x 8 bytes x block size fit int byte offsets, floor((2^31 - 1) / (8 x block size)) doubles per thread; the plan throws above it"));
        }
    }

    // The width limit of the plan: the scratch doubles of one thread times 8 bytes times the block size must not
    // exceed int.MaxValue.
    internal static long MaximumWindowWidth(int source, int blockSize)
    {
        // A quadratic source has no scratch at width 1, so width 2 tells a source without scratch from one with.
        if (WindowCudaBlockCatalog.ScratchDoubles(source, 2) == 0)
            return int.MaxValue;
        long limit = int.MaxValue / (sizeof(double) * (long)blockSize);
        long low = 1;
        long high = int.MaxValue;
        while (low < high)
        {
            var middle = low + ((high - low + 1) / 2);
            if (WindowCudaBlockCatalog.ScratchDoubles(source, middle) <= limit)
                low = middle;
            else
                high = middle - 1;
        }

        return low;
    }

    private static void AddFused(List<MathBlockLimit> limits, MathBlocksCudaOptions cuda)
    {
        limits.Add(new MathBlockLimit(
            "cuda.fused.maximum-blocks", null, MathBlockLimitKind.Launch, MathBlockLimitDevice.Cuda,
            1, int.MaxValue, cuda.FusedMaximumBlocks, "blocks",
            $"{CudaOptions}.{nameof(MathBlocksCudaOptions.FusedMaximumBlocks)}", NoDrivers, SpeedOnly));
        limits.Add(new MathBlockLimit(
            "cuda.fused.block-size", null, MathBlockLimitKind.Launch, MathBlockLimitDevice.Cuda,
            1, MathBlockLimitSeam.MaximumThreadsPerBlock, cuda.FusedBlockSize, "threads",
            $"{CudaOptions}.{nameof(MathBlocksCudaOptions.FusedBlockSize)}", NoDrivers, SpeedOnly));
        limits.Add(new MathBlockLimit(
            "fused.row-block", null, MathBlockLimitKind.Launch, MathBlockLimitDevice.CoreCLR,
            1, int.MaxValue, MathBlockLimitSeam.FusedRowBlock(cuda), "rows",
            $"{CudaOptions}.FusedRowBlock", NoDrivers,
            "rows one CoreCLR task evaluates; every row is independent and the invalid masks combine by bitwise or, so " + SpeedOnly));
        limits.Add(Fixed("fused.maximum-operation-nodes", MathBlockLimitDevice.All, MathBlockFusedExpression.MaximumOperationNodes, "nodes",
            "one invalid-mask bit per operation node, and the mask is 64 bits wide"));
        limits.Add(Fixed("fused.maximum-vector-inputs", MathBlockLimitDevice.All, MathBlockFusedExpression.MaximumVectorInputs, "inputs",
            "the fused kernel binds at most 16 vector inputs"));
        limits.Add(Fixed("fused.maximum-outputs", MathBlockLimitDevice.All, MathBlockFusedExpression.MaximumOutputs, "outputs",
            "the fused kernel writes at most 4 outputs"));
        limits.Add(Fixed("fused.maximum-source-arity", MathBlockLimitDevice.All, 3, "inputs",
            "an elementwise form joins a fused expression only when its source operation has at most 3 arguments"));
        limits.Add(Fixed("fused.operation-count", MathBlockLimitDevice.All, 26 + ElementwiseCudaBlockCatalog.Features.Length, "operations",
            "the 26 pointwise operations and the elementwise forms with their valid siblings are the only operations a fused expression accepts; vector constants come in as inputs"));
    }

    private static void AddWindowAndSequenceRules(List<MathBlockLimit> limits)
    {
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            if (operation.ConstantRefinement is null)
                continue;
            var isLag = string.Equals(operation.Identifier, "sequence.difference", StringComparison.Ordinal);
            limits.Add(new MathBlockLimit(
                isLag ? "domain.lag" : "domain.rolling-width", operation.Identity, MathBlockLimitKind.Domain, MathBlockLimitDevice.All,
                1, null, null, "rows", null, NoDrivers,
                isLag
                    ? "an integer from 1 to the input length minus 1; the input length is the largest lag"
                    : "an integer from 1 to the input length; the input length is the largest width"));
        }
    }

    private static void AddDomain(List<MathBlockLimit> limits, MathBlockDomainOptions domain)
    {
        foreach (var entry in DomainEntries())
        {
            foreach (var operation in entry.Operations)
            {
                limits.Add(new MathBlockLimit(
                    entry.Name, operation, MathBlockLimitKind.Domain, MathBlockLimitDevice.All,
                    entry.Minimum, entry.Maximum, entry.Read(domain), entry.Unit,
                    $"{DomainOptions}.{entry.Option}", NoDrivers, entry.Rule));
            }
        }
    }

    private static void AddDeviceModule(List<MathBlockLimit> limits, MathBlocksCudaOptions cuda, MathBlockDomainOptions domain)
    {
        limits.Add(new MathBlockLimit(
            "cuda.device-module.dispatcher-block-size", null, MathBlockLimitKind.Option, MathBlockLimitDevice.Cuda,
            1, null, cuda.BlockSize, "threads",
            $"{CudaOptions}.{nameof(MathBlocksCudaOptions.BlockSize)}", NoDrivers,
            "caller-launched; the caller checks against its own kernel's maximum threads per block"));
        foreach (var entry in DomainEntries())
        {
            limits.Add(new MathBlockLimit(
                "cuda.device-module." + entry.Name["domain.".Length..], null, MathBlockLimitKind.Domain, MathBlockLimitDevice.Cuda,
                entry.Minimum, entry.Maximum, entry.Read(domain), entry.Unit,
                $"{DomainOptions}.{entry.Option}", NoDrivers,
                "a parameter of the generated device-module source, equal to the domain limit " + entry.Name + " that CoreCLR applies"));
        }
    }

    private static void AddNotation(List<MathBlockLimit> limits)
    {
        var openMath = nameof(MathBlockOpenMathImportOptions);
        var interchange = nameof(MathBlockFormulaInterchangeOptions);
        var stringMaximum = MathBlockOpenMathImportOptions.MaximumStringLength;
        limits.Add(Option("openmath.maximum-nodes", MathBlockLimitDevice.All, 1, int.MaxValue, int.MaxValue, "nodes", $"{openMath}.MaximumNodes",
            "program nodes an OpenMath import accepts; unbounded by default"));
        limits.Add(Option("openmath.maximum-outputs", MathBlockLimitDevice.All, 1, int.MaxValue, int.MaxValue, "outputs", $"{openMath}.MaximumOutputs",
            "program outputs an OpenMath import accepts; unbounded by default"));
        limits.Add(Option("openmath.maximum-value-elements", MathBlockLimitDevice.All, 1, int.MaxValue, int.MaxValue, "elements", $"{openMath}.MaximumValueElements",
            "constant value elements an OpenMath import accepts; unbounded by default"));
        limits.Add(Option("openmath.maximum-document-characters", MathBlockLimitDevice.All, 1, stringMaximum, MathBlockOpenMath.MaximumDocumentCharacters, "characters", $"{openMath}.MaximumDocumentCharacters",
            "the maximum is the longest .NET string, 0x3FFFFFDF characters"));
        limits.Add(Option("openmath.maximum-document-bytes", MathBlockLimitDevice.All, 1, Array.MaxLength, MathBlockOpenMath.MaximumDocumentUtf8Bytes, "bytes", $"{openMath}.MaximumDocumentBytes",
            "the maximum is the longest .NET byte array, Array.MaxLength"));
        limits.Add(Option("interchange.maximum-document-characters", MathBlockLimitDevice.All, 1, stringMaximum, MathBlockFormulaInterchange.MaximumDocumentCharacters, "characters", $"{interchange}.MaximumDocumentCharacters",
            "the maximum is the longest .NET string, 0x3FFFFFDF characters"));
        limits.Add(Option("interchange.maximum-document-utf8-bytes", MathBlockLimitDevice.All, 1, Array.MaxLength, MathBlockFormulaInterchange.MaximumDocumentUtf8Bytes, "bytes", $"{interchange}.MaximumDocumentUtf8Bytes",
            "the maximum is the longest .NET byte array, Array.MaxLength"));
        limits.Add(Option("interchange.maximum-expression-elements", MathBlockLimitDevice.All, 1, Array.MaxLength, MathBlockFormulaInterchange.MaximumExpressionElements, "elements", $"{interchange}.MaximumExpressionElements",
            "the maximum is the longest .NET array, Array.MaxLength"));
        limits.Add(Option("interchange.maximum-expression-depth", MathBlockLimitDevice.All, 1, Array.MaxLength, MathBlockFormulaInterchange.MaximumExpressionDepth, "levels", $"{interchange}.MaximumExpressionDepth",
            "each level is a buffered element, so the maximum is the longest .NET array; the parser is recursive and rejects an expression deeper than the stack allows"));
        limits.Add(Option("coreclr.maximum-concurrency", MathBlockLimitDevice.CoreCLR, -1, int.MaxValue, -1, "threads", "MathBlocksCoreCLRWorker.MaximumConcurrency",
            "a constructor argument: -1 for no limit, otherwise at least 1; 0 and values below -1 throw"));
    }

    private static void AddFixed(List<MathBlockLimit> limits)
    {
        limits.Add(Fixed("units.dimension-count", MathBlockLimitDevice.All, 4, "dimensions",
            "a unit has exactly four independent base dimensions"));
        limits.Add(new MathBlockLimit(
            "units.exponent-component", null, MathBlockLimitKind.Fixed, MathBlockLimitDevice.All,
            int.MinValue, int.MaxValue, null, "integer", null, NoDrivers,
            "exponents are rationals whose numerator and denominator are int32; a power or product that leaves int32 throws OverflowException instead of giving Invalid"));
        limits.Add(Fixed("matrix.exponential.taylor-terms", "matrix.exponential@1", MathBlockLimitDevice.All, 48, "terms",
            "a free choice: after scaling to norm at most 1 the remainder after n terms is below 1/(n + 1)!, under 2^-53 from n = 18; 48 terms are a margin, and the count is part of the bit contract between CoreCLR and CUDA"));
        limits.Add(Fixed("scalar.cube-root.newton-steps", "scalar.cube-root@1", MathBlockLimitDevice.All, 3, "steps",
            "a free choice: the exp(ln(x) / 3) start is within about 3e-14 relative (estimated, not measured), and one Newton step squares that error below 2^-53, and the count is part of the bit contract between CoreCLR and CUDA"));
        limits.Add(Fixed("packaging.cuda-toolkit-minimum-major", MathBlockLimitDevice.Cuda, 12, "version",
            "the NVRTC loader accepts CUDA Toolkit 12.0 or later"));
        limits.Add(Fixed("packaging.profile-1-operation-count", MathBlockLimitDevice.All, MathBlockFeatureIndex.Count, "operations",
            "Profile 1 requires exactly this many operations, so a new operation needs a new profile"));
        limits.Add(new MathBlockLimit(
            "packaging.target-framework", null, MathBlockLimitKind.Fixed, MathBlockLimitDevice.All,
            null, null, null, "framework", null, NoDrivers,
            "net10.0 only, with no native binaries"));
    }

    private static IEnumerable<DomainEntry> DomainEntries()
    {
        const string rows = "rows";
        yield return new("domain.maximum-explicit-subset-size", nameof(MathBlockDomainOptions.MaximumExplicitSubsetSize), "elements",
            1, MathBlockDomainOptions.MaximumExplicitSubsetSizeInScratch, d => d.MaximumExplicitSubsetSize,
            ["matrix.principal-minors@1", "combinatorics.nonempty-subset-sums@1", "transport.minimum-assignment@1"],
            "the scratch holds 2^n values of 8 bytes addressed with int byte offsets, so n is at most 26");
        yield return new("domain.maximum-state-count", nameof(MathBlockDomainOptions.MaximumStateCount), "states",
            1, MathBlockDomainOptions.MaximumSquareMatrixSizeInIntBytes, d => d.MaximumStateCount,
            ["state.transition-counts@1"],
            "the count matrix holds n x n doubles addressed with int byte offsets, so n is at most 16,383");
        yield return new("domain.maximum-generated-vector-length", nameof(MathBlockDomainOptions.MaximumGeneratedVectorLength), "elements",
            1, MathBlockDomainOptions.MaximumVectorLengthInIntBytes, d => d.MaximumGeneratedVectorLength,
            ["vector.repeat@1", "vector.linspace@1"],
            "the output holds 8-byte values addressed with int byte offsets, so its length is at most 268,435,455");
        yield return new("domain.maximum-submodular-set-function-values", nameof(MathBlockDomainOptions.MaximumSubmodularSetFunctionValues), "values",
            1, MathBlockDomainOptions.MaximumSetFunctionValuesInArray, d => d.MaximumSubmodularSetFunctionValues,
            ["capacity.is-submodular@1"],
            "the length is a power of two and a .NET array length, so at most 2^30");
        yield return new("domain.maximum-shapley-coalition-values", nameof(MathBlockDomainOptions.MaximumShapleyCoalitionValues), "values",
            1, MathBlockDomainOptions.MaximumSetFunctionValuesInArray, d => d.MaximumShapleyCoalitionValues,
            ["cooperative.shapley-values@1"],
            "the length is a power of two and a .NET array length, so at most 2^30");
        yield return new("domain.maximum-choquet-player-count", nameof(MathBlockDomainOptions.MaximumChoquetPlayerCount), "players",
            1, MathBlockDomainOptions.MaximumMaskWidth, d => d.MaximumChoquetPlayerCount,
            ["capacity.choquet-integral@1"],
            "a coalition is a bit mask in an int, so at most 30 players");
        yield return new("domain.maximum-maximal-minor-columns", nameof(MathBlockDomainOptions.MaximumMaximalMinorColumns), "columns",
            1, MathBlockDomainOptions.MaximumMaskWidth, d => d.MaximumMaximalMinorColumns,
            ["matrix.maximal-minors@1"],
            "a column subset is a bit mask in an int, so at most 30 columns");
        yield return new("domain.maximum-totally-nonnegative-size", nameof(MathBlockDomainOptions.MaximumTotallyNonnegativeSize), rows,
            1, MathBlockDomainOptions.MaximumMaskWidth, d => d.MaximumTotallyNonnegativeSize,
            ["matrix.is-totally-nonnegative@1"],
            "a row or column subset is a bit mask in an int, so at most 30 rows and columns");
        yield return new("domain.maximum-matrix-size", nameof(MathBlockDomainOptions.MaximumMatrixSize), rows,
            1, MathBlockDomainOptions.MaximumSquareMatrixSizeInIntBytes, d => d.MaximumMatrixSize,
            ["matrix.identity@1"],
            "the matrix holds n x n doubles addressed with int byte offsets, so n is at most 16,383");
        yield return new("domain.maximum-iteration-count", nameof(MathBlockDomainOptions.MaximumIterationCount), "iterations",
            1, int.MaxValue, d => d.MaximumIterationCount,
            ["matrix.perron-vector@1", "matrix.perron-value@1", "matrix.spectral-norm@1", "markov.stationary-distribution@1", "graph.page-rank@1", "transport.sinkhorn-coupling@1"],
            "the count and its loop counter are ints");
        yield return new("domain.incomplete-beta-maximum-iterations", nameof(MathBlockDomainOptions.IncompleteBetaMaximumIterations), "iterations",
            1, int.MaxValue - 1, d => d.IncompleteBetaMaximumIterations,
            ["special.regularized-incomplete-beta@1"],
            "continued-fraction steps before the last estimate is used; the loop counter is an int that must not wrap");
        yield return new("domain.incomplete-beta-non-convergence", nameof(MathBlockDomainOptions.IncompleteBetaNonConvergence), "policy",
            0, 1, d => (long)d.IncompleteBetaNonConvergence,
            ["special.regularized-incomplete-beta@1"],
            "0 returns the last estimate as a valid value, 1 returns an invalid row, when the continued fraction has not converged");
        string[] jacobi = ["matrix.symmetric-eigenvalues@1", "matrix.largest-symmetric-eigenvalue@1", "matrix.smallest-symmetric-eigenvalue@1", "matrix.spectral-norm@1", "graph.algebraic-connectivity@1"];
        yield return new("domain.jacobi-rotation-multiplier", nameof(MathBlockDomainOptions.JacobiRotationMultiplier), "rotations per n x n",
            1, int.MaxValue, d => d.JacobiRotationMultiplier, jacobi,
            "the rotation budget is the multiplier x n x n, counted in 64-bit integers");
        yield return new("domain.jacobi-non-convergence", nameof(MathBlockDomainOptions.JacobiNonConvergence), "policy",
            0, 1, d => (long)d.JacobiNonConvergence, jacobi,
            "0 returns the eigenvalues at the budget, 1 returns an invalid row, when the off-diagonal part is not zero at the budget");
    }

    private static MathBlockLimit Fixed(string name, MathBlockLimitDevice device, long? value, string unit, string rule) =>
        new(name, null, MathBlockLimitKind.Fixed, device, null, null, value, unit, null, NoDrivers, rule);

    private static MathBlockLimit Fixed(string name, string operation, MathBlockLimitDevice device, long value, string unit, string rule) =>
        new(name, operation, MathBlockLimitKind.Fixed, device, null, null, value, unit, null, NoDrivers, rule);

    private static MathBlockLimit Option(
        string name,
        MathBlockLimitDevice device,
        long minimum,
        long maximum,
        long value,
        string unit,
        string option,
        string rule) =>
        new(name, null, MathBlockLimitKind.Option, device, minimum, maximum, value, unit, option, NoDrivers, rule);
}
