namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ExtensionMcshaneV1Block
    {
        internal const string Identity = "extension.mcshane@1";
        internal static MathBlockOperation Create() => CreateLipschitzExtension("extension.mcshane", MathBlockAdvanced.McShaneExtension);
    }
}
