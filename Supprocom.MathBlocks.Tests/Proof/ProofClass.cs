namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The input classes of the proof matrix. Every class is a separate input set of the same size. Mixed takes row r from the base class at index r modulo seven, so every
/// 32-row warp and every series holds all seven base classes; AllFalse is the all-false predicate that first-true-offset scans in full.
/// </summary>
internal enum ProofClass
{
    Typical,
    Counts,
    Extreme,
    NearOverflow,
    Subnormal,
    Invalid,
    DomainEdge,
    Mixed,
    AllFalse
}
