namespace Supprocom.MathBlocks.Cuda;

// The opcode of an elementwise form or sibling: 2 * source + sibling, plus the mask of vector arguments (bit k set when argument k is a vector).
// A source below 64 keeps the encoding of every earlier version: 2 * source + sibling + 128 * mask, below 1024 for every mask 0 to 7. A larger
// source is 1024 + (2 * source + sibling) + 65536 * mask. The kernel decodes the same way (ElementwiseModule.cs), and the two sides share these constants.
internal static class MathBlockCudaElementwiseOpcode
{
    internal const int LegacySourceCount = 64;
    internal const int LegacyMaskStep = 128;
    internal const int WideBase = 1024;
    internal const int WideMaskStep = 65_536;
    internal const int MaskCount = 8;

    // The largest source index: 2 * source + 1 must stay below the wide mask step, and the largest opcode, with mask 7, below 2^31.
    internal const int MaximumSourceIndex = WideMaskStep / 2 - 1;

    // The number of sources the encoding holds.
    internal const int MaximumSourceCount = MaximumSourceIndex + 1;

    // The opcode of a source with the given mask; a mask of 0 is the contract opcode.
    internal static int Encode(int source, bool sibling, int mask)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(source);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(source, MaximumSourceIndex);
        ArgumentOutOfRangeException.ThrowIfNegative(mask);
        ArgumentOutOfRangeException.ThrowIfGreaterThanOrEqual(mask, MaskCount);
        var form = 2 * source + (sibling ? 1 : 0);
        return source < LegacySourceCount ? form + LegacyMaskStep * mask : WideBase + form + WideMaskStep * mask;
    }

    // The contract opcode (mask 0) with the mask of vector arguments added.
    internal static int AddMask(int contractOpcode, int mask) =>
        checked(contractOpcode < WideBase ? contractOpcode + LegacyMaskStep * mask : contractOpcode + WideMaskStep * mask);

    internal static (int Source, bool Sibling, int Mask) Decode(int opcode)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(opcode);
        var mask = opcode < WideBase ? opcode / LegacyMaskStep : (opcode - WideBase) / WideMaskStep;
        var form = opcode < WideBase ? opcode % LegacyMaskStep : (opcode - WideBase) % WideMaskStep;
        return (form / 2, form % 2 != 0, mask);
    }
}
