namespace Supprocom.CSharp2CUDA;

// The CSharp2CUDA package attribute that the type-rule translation unit
// (MathBlocks.CudaSourceGenerator/TranslationUnits/TypeRuleUnit.cs) carries. The unit is compiled into this assembly so the host runs the very
// statements the generator transpiles; the attribute has no run-time effect here, and the package itself is not a dependency of this assembly.
[AttributeUsage(AttributeTargets.Method)]
internal sealed class CudaDeviceAttribute : Attribute
{
    public string? Name { get; init; }
}
