using System.Globalization;

namespace Supprocom.MathBlocks;

/// <summary>Sets operation domain limits. They change which rows are valid, so CoreCLR and CUDA must use the same values.</summary>
/// <remarks>Every default is the value earlier versions hard-coded. A value outside its range throws <see cref="ArgumentOutOfRangeException"/> when the options are loaded, naming the limit that bounds it.</remarks>
public sealed class MathBlockDomainOptions
{
    // The largest int such that a count of 8-byte values fits int byte offsets: (2^31 - 1) / 8.
    internal const int MaximumVectorLengthInIntBytes = 268_435_455;
    // The largest square matrix whose n * n doubles fit int byte offsets: floor(sqrt((2^31 - 1) / 8)).
    internal const int MaximumSquareMatrixSizeInIntBytes = 16_383;
    // The largest power of two that is a valid .NET array length (Array.MaxLength is 2,147,483,591).
    internal const int MaximumSetFunctionValuesInArray = 1 << 30;
    // The int bit-mask width: a coalition or column mask is 1 << n in an int, so n is at most 30.
    internal const int MaximumMaskWidth = 30;
    // The explicit-subset scratch is 2^n values of 8 bytes in int byte offsets: 2^26 * 8 = 2^29 leaves room for the working arrays beside it.
    internal const int MaximumExplicitSubsetSizeInScratch = 26;

    /// <summary>Gets the option set with today's domain limits.</summary>
    public static MathBlockDomainOptions Default { get; } = new();

    /// <summary>Gets the largest size of an explicit subset enumeration: the matrix rows of <c>matrix.principal-minors</c>, the values of <c>combinatorics.nonempty-subset-sums</c> and the matrix rows of <c>transport.minimum-assignment</c>. The range is 1 to 26: the scratch holds 2^n values addressed with int byte offsets.</summary>
    public int MaximumExplicitSubsetSize { get; init; } = 20;

    /// <summary>Gets the largest state count of <c>state.transition-counts</c>. The range is 1 to 16,383: the count matrix holds n * n doubles addressed with int byte offsets.</summary>
    public int MaximumStateCount { get; init; } = 4_096;

    /// <summary>Gets the largest output length of <c>vector.repeat</c> and <c>vector.linspace</c>. The range is 1 to 268,435,455: the vector holds 8-byte values addressed with int byte offsets.</summary>
    public int MaximumGeneratedVectorLength { get; init; } = 1_000_000;

    /// <summary>Gets the largest set-function length of <c>capacity.is-submodular</c>. The range is 1 to 2^30: the length is a power of two and a .NET array length.</summary>
    public int MaximumSubmodularSetFunctionValues { get; init; } = 1 << 12;

    /// <summary>Gets the largest coalition-value length of <c>cooperative.shapley-values</c>. The range is 1 to 2^30: the length is a power of two and a .NET array length.</summary>
    public int MaximumShapleyCoalitionValues { get; init; } = 1 << 20;

    /// <summary>Gets the largest player count of <c>capacity.choquet-integral</c>. The range is 1 to 30: a coalition is a bit mask in an int.</summary>
    public int MaximumChoquetPlayerCount { get; init; } = 30;

    /// <summary>Gets the largest column count of <c>matrix.maximal-minors</c>. The range is 1 to 30: a column subset is a bit mask in an int.</summary>
    public int MaximumMaximalMinorColumns { get; init; } = 20;

    /// <summary>Gets the largest row and column count of <c>matrix.is-totally-nonnegative</c>. The range is 1 to 30: a row or column subset is a bit mask in an int.</summary>
    public int MaximumTotallyNonnegativeSize { get; init; } = 8;

    /// <summary>Gets the largest size of <c>matrix.identity</c>. The range is 1 to 16,383: the matrix holds n * n doubles addressed with int byte offsets.</summary>
    public int MaximumMatrixSize { get; init; } = 4_096;

    /// <summary>Gets the largest iteration count of <c>matrix.perron-vector</c>, <c>matrix.perron-value</c>, <c>matrix.spectral-norm</c>, <c>markov.stationary-distribution</c>, <c>graph.page-rank</c> and <c>transport.sinkhorn-coupling</c>. The range is 1 to 2,147,483,647: the count and its loop counter are ints.</summary>
    public int MaximumIterationCount { get; init; } = 10_000;

    /// <summary>Gets the largest number of continued-fraction steps of the regularized incomplete beta function. The range is 1 to 2,147,483,646: the loop counter is an int that must not wrap.</summary>
    public int IncompleteBetaMaximumIterations { get; init; } = 256;

    /// <summary>Gets the relative step size at which the incomplete beta continued fraction counts as converged. The range is 0 to 1 and finite.</summary>
    public double IncompleteBetaTolerance { get; init; } = 3e-14;

    /// <summary>Gets what the incomplete beta function returns when the continued fraction has not converged at its iteration budget.</summary>
    public MathBlockNonConvergencePolicy IncompleteBetaNonConvergence { get; init; } = MathBlockNonConvergencePolicy.Estimate;

    /// <summary>Gets the number of Taylor terms of <c>matrix.exponential@1</c> after the matrix is scaled to norm at most 1. The range is 1 to 2,147,483,646.</summary>
    /// <remarks>A free choice, not derived for correct rounding: the remainder after n terms is below 1/(n + 1)!, under 2^-53 from n = 18, and the default 48 is a margin. The count is part of the bit contract between CoreCLR and CUDA, which use the same value.</remarks>
    public int MatrixExponentialTaylorTerms { get; init; } = 48;

    /// <summary>Gets the number of Newton steps of <c>scalar.cube-root@1</c> after the exp(ln(x) / 3) start. The range is 0 to 2,147,483,646.</summary>
    /// <remarks>A free choice, not derived for correct rounding: the start is within about 3e-14 relative (estimated, not measured), and one step squares that error below 2^-53. The count is part of the bit contract between CoreCLR and CUDA, which use the same value in the scalar operation and its elementwise forms.</remarks>
    public int CubeRootNewtonSteps { get; init; } = 3;

    /// <summary>Gets the multiplier of the Jacobi eigenvalue rotation budget, which is the multiplier times n times n rotations for an n by n matrix. The range is 1 to 2,147,483,647; the budget is counted in 64-bit integers.</summary>
    public int JacobiRotationMultiplier { get; init; } = 64;

    /// <summary>Gets what the Jacobi eigenvalue computation returns when the rotation budget ends before the off-diagonal part is zero.</summary>
    public MathBlockNonConvergencePolicy JacobiNonConvergence { get; init; } = MathBlockNonConvergencePolicy.Estimate;

    // Throws ArgumentOutOfRangeException naming the option and its real bound when a value is outside its range.
    internal void Validate()
    {
        Require(MaximumExplicitSubsetSize, 1, MaximumExplicitSubsetSizeInScratch, nameof(MaximumExplicitSubsetSize), "the explicit-subset scratch holds 2^n values addressed with int byte offsets");
        Require(MaximumStateCount, 1, MaximumSquareMatrixSizeInIntBytes, nameof(MaximumStateCount), "the count matrix holds n * n doubles addressed with int byte offsets");
        Require(MaximumGeneratedVectorLength, 1, MaximumVectorLengthInIntBytes, nameof(MaximumGeneratedVectorLength), "the vector holds 8-byte values addressed with int byte offsets");
        Require(MaximumSubmodularSetFunctionValues, 1, MaximumSetFunctionValuesInArray, nameof(MaximumSubmodularSetFunctionValues), "the set-function length is a power of two and a .NET array length");
        Require(MaximumShapleyCoalitionValues, 1, MaximumSetFunctionValuesInArray, nameof(MaximumShapleyCoalitionValues), "the coalition-value length is a power of two and a .NET array length");
        Require(MaximumChoquetPlayerCount, 1, MaximumMaskWidth, nameof(MaximumChoquetPlayerCount), "a coalition is a bit mask in an int");
        Require(MaximumMaximalMinorColumns, 1, MaximumMaskWidth, nameof(MaximumMaximalMinorColumns), "a column subset is a bit mask in an int");
        Require(MaximumTotallyNonnegativeSize, 1, MaximumMaskWidth, nameof(MaximumTotallyNonnegativeSize), "a row or column subset is a bit mask in an int");
        Require(MaximumMatrixSize, 1, MaximumSquareMatrixSizeInIntBytes, nameof(MaximumMatrixSize), "the matrix holds n * n doubles addressed with int byte offsets");
        Require(MaximumIterationCount, 1, int.MaxValue, nameof(MaximumIterationCount), "the count and its loop counter are ints");
        Require(IncompleteBetaMaximumIterations, 1, int.MaxValue - 1, nameof(IncompleteBetaMaximumIterations), "the loop counter is an int that must not wrap");
        if (!(IncompleteBetaTolerance >= 0d && IncompleteBetaTolerance <= 1d))
        {
            throw new ArgumentOutOfRangeException(
                nameof(IncompleteBetaTolerance),
                IncompleteBetaTolerance,
                "IncompleteBetaTolerance must be a number from 0 to 1.");
        }
        if (!Enum.IsDefined(IncompleteBetaNonConvergence))
        {
            throw new ArgumentOutOfRangeException(
                nameof(IncompleteBetaNonConvergence),
                IncompleteBetaNonConvergence,
                "IncompleteBetaNonConvergence is not a defined policy.");
        }
        Require(MatrixExponentialTaylorTerms, 1, int.MaxValue - 1, nameof(MatrixExponentialTaylorTerms), "the term counter is an int that must not wrap");
        Require(CubeRootNewtonSteps, 0, int.MaxValue - 1, nameof(CubeRootNewtonSteps), "the step counter is an int that must not wrap");
        Require(JacobiRotationMultiplier, 1, int.MaxValue, nameof(JacobiRotationMultiplier), "the budget is counted in 64-bit integers, so the multiplier is an int");
        if (!Enum.IsDefined(JacobiNonConvergence))
        {
            throw new ArgumentOutOfRangeException(
                nameof(JacobiNonConvergence),
                JacobiNonConvergence,
                "JacobiNonConvergence is not a defined policy.");
        }
    }

    private static void Require(int value, int minimum, int maximum, string name, string reason)
    {
        if (value < minimum || value > maximum)
        {
            throw new ArgumentOutOfRangeException(
                name,
                value,
                string.Create(
                    CultureInfo.InvariantCulture,
                    $"{name} must be from {minimum:N0} to {maximum:N0}: {reason}."));
        }
    }
}
