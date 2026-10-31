namespace Supprocom.MathBlocks;

// One row of a fused expression holds each node's value for that row in one of four kinds of register.
internal enum MathBlockFusedKind
{
    Number,
    Scalar,
    Flag,
    Complex
}
