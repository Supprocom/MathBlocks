namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ExtensionWhitneyV1Block
    {
        internal const string Identity = "extension.whitney@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateLipschitzExtension("extension.whitney", MathBlockAdvanced.WhitneyExtension);
    }
}
