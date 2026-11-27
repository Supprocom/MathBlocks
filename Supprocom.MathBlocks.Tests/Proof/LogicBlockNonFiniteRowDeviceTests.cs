using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// A vector never holds a value that is not finite, so on CoreCLR an operand vector with a NaN or an infinite row is an invalid value and the result of the block is invalid. A consumer's
/// own slot can be valid and still hold such a row. The device must give the same invalid result: the vector comparisons and the vector select (a row of either branch counts, whichever the
/// condition takes) make the whole output invalid, as the arithmetic vector forms already do. The Boolean-vector blocks have no float operand, so a row cannot be non-finite there.
/// </summary>
public sealed class LogicBlockNonFiniteRowDeviceTests
{
    private const int Rows = 33;

    private static readonly float[] BadValues = [float.NaN, float.PositiveInfinity, float.NegativeInfinity];
    private static readonly int[] BadRows = [0, Rows / 2, Rows - 1];

    /// <summary>Verifies the vector comparisons and the vector select give an invalid result when any float operand has a NaN or an infinite row at the first, a middle or the last row.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void AVectorOperandRowThatIsNotFiniteMakesTheDeviceResultInvalidAsOnCoreCLR()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var failures = new List<string>();
        string[] identities = [.. LogicBlocks.VectorComparisons, LogicBlocks.VectorSelect];
        using var device = new VectorBlockDevice();
        for (var identityIndex = 0; identityIndex < identities.Length; identityIndex++)
        {
            var identity = identities[identityIndex];
            var contract = MathBlockCudaDeviceModule.GetOperation(identity);
            var valid = LogicBlocks.ParityCases(identity).First(inputs => inputs.All(input => input.IsValid) && Count(inputs[0]) == Rows);
            var call = new VectorBlockCall(identity, "plain", "-", 1f, 0f, [identity], 1);
            for (var operand = 0; operand < valid.Length; operand++)
            {
                if (valid[operand].Type.Kind != MathBlockValueKind.Vector)
                    continue;
                for (var valueIndex = 0; valueIndex < BadValues.Length; valueIndex++)
                {
                    for (var rowIndex = 0; rowIndex < BadRows.Length; rowIndex++)
                    {
                        using var run = new VectorBlockRun(device, call, [valid]);
                        run.SetInputRow(0, operand, BadRows[rowIndex], BadValues[valueIndex]);
                        var actual = run.Execute()[0];
                        var withInvalid = (MathBlockValue[])valid.Clone();
                        withInvalid[operand] = MathBlockValue.Invalid(valid[operand].Type, "A row is not finite.");
                        var difference = LogicBlocks.Difference(contract.EvaluateCoreCLR(withInvalid), actual);
                        if (difference is not null && failures.Count < 20)
                            failures.Add(string.Create(CultureInfo.InvariantCulture, $"{identity} operand {operand} row {BadRows[rowIndex]} value {BadValues[valueIndex]}: {difference}"));
                    }
                }
            }

            // The control: the same operands without a bad row are valid and equal CoreCLR.
            using var control = new VectorBlockRun(device, call, [valid]);
            var controlDifference = LogicBlocks.Difference(contract.EvaluateCoreCLR(valid), control.Execute()[0]);
            if (controlDifference is not null)
                failures.Add($"{identity} control: {controlDifference}");
        }

        ProofBar.Fail("Non-finite operand rows", failures);
    }

    private static int Count(MathBlockValue value) => value.Type.Kind == MathBlockValueKind.Vector ? value.AsVector().Count : value.AsBooleanVector().Count;
}
