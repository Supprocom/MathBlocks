using System.Reflection;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies without a CUDA device that the CUDA planner accepts the programs the CUDA tests compile from prototype inputs:
/// it runs <c>MathBlocksCUDAProgram.PlanArena</c>, the planning of <c>Create</c> up to its first device call (the program
/// validation, every node's payload layout including the constant folding of scalar nodes, the arena and the scratch), and
/// the plan must not throw. A plan that throws here would fail the CUDA test at its <c>Compile</c> call before any kernel runs.
/// </summary>
public sealed class MathBlockCudaPlanGateTests
{
    private static readonly MethodInfo PlanArena = typeof(MathBlockCudaDeviceModule).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!
        .GetMethod("PlanArena", BindingFlags.Static | BindingFlags.NonPublic)!;

    /// <summary>Gets the names of the self-compiled CUDA cases.</summary>
    public static TheoryData<string> SelfCompiledNames => MathBlockCudaWorkerTests.SelfCompiledCaseNames;

    /// <summary>Gets the identities of every Standard operation.</summary>
    public static TheoryData<string> Identities => [.. MathBlockCatalog.Standard.Operations.Select(operation => operation.Identity).Order(StringComparer.Ordinal)];

    /// <summary>Verifies the planner accepts every self-compiled case.</summary>
    [Theory]
    [MemberData(nameof(SelfCompiledNames))]
    [Trait("Category", "InvalidState")]
    public void CUDAPlanAcceptsEverySelfCompiledCase(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        var (program, inputs) = MathBlockCudaWorkerTests.SelfCompiledCases[name]();
        Plan(program, inputs);
    }

    /// <summary>Verifies the planner accepts a program of each operation compiled from its regression sample.</summary>
    [Theory]
    [MemberData(nameof(Identities))]
    [Trait("Category", "InvalidState")]
    public void CUDAPlanAcceptsEachOperationCompiledFromItsSample(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var operation = MathBlockCatalog.Standard.Get(identity.Split('@')[0]);
        var sample = operation.RegressionCases[0].Inputs.ToArray();
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = sample.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        Plan(builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build(), sample);
    }

    private static void Plan(MathBlockProgram program, MathBlockValue[] inputs)
    {
        var named = inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
            .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
        try
        {
            PlanArena.Invoke(null, [program, named]);
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            Assert.Fail($"The CUDA plan threw {exception.InnerException.GetType().Name}: {exception.InnerException.Message}");
        }
    }
}
