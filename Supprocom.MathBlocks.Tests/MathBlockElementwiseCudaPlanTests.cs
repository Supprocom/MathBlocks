using System.Reflection;
using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CUDA contracts and plans of the elementwise forms without a CUDA device.</summary>
public sealed class MathBlockElementwiseCudaPlanTests
{
    private static readonly Type Catalog = typeof(MathBlockCudaDeviceModule).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.ElementwiseCudaBlockCatalog", throwOnError: true)!;

    /// <summary>
    /// Verifies each elementwise form and sibling has a family 12 contract with opcode 2 * source + sibling, a
    /// block of 128 threads and the arity of the CoreCLR form, while the forms stay outside Standard.
    /// </summary>
    [Fact]
    public void ElementwiseCUDAContractsUseFamilyTwelveWithOpcodeTwiceTheSourcePlusSibling()
    {
        Assert.Equal(12, (int)MathBlockCudaOperationFamily.Elementwise);
        for (var index = 0; index < SourceIdentifiers.Length; index++)
        {
            var form = MathBlockCudaDeviceModule.GetOperation($"elementwise.{SourceIdentifiers[index]}@1");
            var sibling = MathBlockCudaDeviceModule.GetOperation($"elementwise-valid.{SourceIdentifiers[index]}@1");
            Assert.Equal(MathBlockCudaOperationFamily.Elementwise, form.Family);
            Assert.Equal(MathBlockCudaOperationFamily.Elementwise, sibling.Family);
            Assert.Equal(2 * index, form.Opcode);
            Assert.Equal(2 * index + 1, sibling.Opcode);
            Assert.Equal(128u, form.NativeBlockSize);
            Assert.Equal(Form(SourceIdentifiers[index]).Arity, form.Arity);
            Assert.Equal(Validity(SourceIdentifiers[index]).Arity, sibling.Arity);
        }

        Assert.Equal(
            82,
            MathBlockCudaDeviceModule.Operations.Count(contract => contract.Family == MathBlockCudaOperationFamily.Elementwise));
        Assert.Equal(537, MathBlocksCUDAWorker.SupportedBlockIdentities.Count);
        Assert.DoesNotContain(
            MathBlockCatalog.Standard.Operations,
            operation => operation.Identifier.StartsWith("elementwise", StringComparison.Ordinal));
    }

    /// <summary>
    /// Verifies the dispatched opcode adds 128 times the mask of vector arguments to the contract opcode, and the
    /// grid has one thread per row in blocks of 128, at least one block and at most 65,535.
    /// </summary>
    [Fact]
    public void ElementwiseCUDAOpcodeCarriesTheArgumentMaskAndTheGridCoversTheRows()
    {
        var dispatchOpcode = Catalog.GetMethod("DispatchOpcode", BindingFlags.NonPublic | BindingFlags.Static)!;
        var gridX = Catalog.GetMethod("GridX", BindingFlags.NonPublic | BindingFlags.Static)!;
        int Opcode(int opcode, params MathBlockType[] types) => (int)dispatchOpcode.Invoke(null, [opcode, types])!;
        int Grid(int rows) => (int)gridX.Invoke(null, [rows])!;
        var vector = MathBlockType.Vector(default, 5);
        var scalar = MathBlockType.Scalar();

        Assert.Equal(24 + 128 * 5, Opcode(24, vector, scalar, vector, scalar));
        Assert.Equal(25 + 128 * 2, Opcode(25, scalar, vector, scalar));
        Assert.Equal(80 + 128 * 7, Opcode(80, vector, vector, vector, scalar));
        Assert.Equal(1, Grid(0));
        Assert.Equal(1, Grid(128));
        Assert.Equal(2, Grid(129));
        Assert.Equal(2_367, Grid(302_893));
        Assert.Equal(65_535, Grid(int.MaxValue));
    }

    /// <summary>
    /// Verifies the plan of every form and sibling: the output holds one row per vector row, with no scratch, for
    /// every broadcast mask.
    /// </summary>
    [Theory]
    [InlineData(1)]
    [InlineData(257)]
    [InlineData(302_893)]
    public void ElementwiseCUDAPlanHoldsOneRowPerVectorRowWithoutScratch(int count)
    {
        foreach (var source in SourceIdentifiers)
        {
            foreach (var mask in BroadcastMasks(source))
            {
                var arguments = CreateArguments(source, count, mask, 17);
                var formPlan = MathBlockCudaDeviceModule.GetOperation($"elementwise.{source}@1")
                    .PlanCUDA([.. arguments, MathBlockValue.Scalar(-1d)]);
                var siblingPlan = MathBlockCudaDeviceModule.GetOperation($"elementwise-valid.{source}@1")
                    .PlanCUDA(arguments);

                Assert.Equal(0, formPlan.ScratchBytes);
                Assert.Equal(0, siblingPlan.ScratchBytes);
                Assert.Equal(count, formPlan.OutputCapacity);
                Assert.Equal(count, formPlan.OutputRows);
                Assert.Equal(count, siblingPlan.OutputCapacity);
                Assert.Equal(count, siblingPlan.OutputRows);
                Assert.Equal(MathBlockValueKind.Vector, formPlan.OutputType.Kind);
                Assert.Equal(MathBlockValueKind.BooleanVector, siblingPlan.OutputType.Kind);
            }
        }
    }

    /// <summary>
    /// Verifies the plan type matches the CoreCLR lift's invalid result: unequal non-empty lengths give no row
    /// authority, and an empty vector next to a non-empty one keeps the non-empty length.
    /// </summary>
    [Fact]
    public void ElementwiseCUDAPlanFollowsTheCoreCLRRowAuthorityForUnequalLengths()
    {
        MathBlockValue[] unequal = [MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([1d, 2d])];
        MathBlockValue[] emptyFirst = [MathBlockValue.Vector([]), MathBlockValue.Vector([1d, 2d])];
        foreach (var arguments in new[] { unequal, emptyFirst })
        {
            MathBlockValue[] inputs = [.. arguments, MathBlockValue.Scalar(-1d)];
            var plan = MathBlockCudaDeviceModule.GetOperation("elementwise.scalar.arc-tangent-2@1").PlanCUDA(inputs);
            var coreclr = Form("scalar.arc-tangent-2").Evaluate(inputs);

            Assert.False(coreclr.IsValid);
            Assert.Equal(coreclr.Type, new MathBlockType(plan.OutputType.Kind, plan.OutputType.Unit, plan.OutputRows, 0));
        }
    }
}
