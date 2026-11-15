using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Builds the one-operation programs that the proof runs on the CUDA worker, with their inputs named input-0, input-1 and so on.</summary>
internal static class ProofPrograms
{
    /// <summary>Builds a program that applies the operation to inputs of the prototype's types and outputs it as <c>result</c>.</summary>
    internal static MathBlockProgram Build(MathBlockOperation operation, MathBlockValue[] prototype)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = new int[prototype.Length];
        for (var index = 0; index < nodes.Length; index++)
            nodes[index] = builder.Input(string.Create(CultureInfo.InvariantCulture, $"input-{index}"), prototype[index].Type);
        return builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
    }

    /// <summary>Names the inputs input-0, input-1 and so on, in order.</summary>
    internal static Dictionary<string, MathBlockValue> Named(MathBlockValue[] inputs)
    {
        var named = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        for (var index = 0; index < inputs.Length; index++)
            named[string.Create(CultureInfo.InvariantCulture, $"input-{index}")] = inputs[index];
        return named;
    }
}
