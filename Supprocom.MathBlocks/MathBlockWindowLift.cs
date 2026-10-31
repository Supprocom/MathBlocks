namespace Supprocom.MathBlocks;

internal enum MathBlockWindowLift
{
    // Row t is the source's scalar result on the trailing window ending at t.
    Scalar,
    // Row t is the source's vector result on that window, taken at the window's last position.
    LastRow
}
