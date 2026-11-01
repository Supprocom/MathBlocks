using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests;

// CoreCLR/CUDA parity of the elementwise forms and siblings: value bits, type, shape and invalid state of the CUDA
// output equal the CoreCLR lift on the same inputs, for every broadcast mask.
public sealed partial class MathBlockCudaWorkerTests
{
    private const int ElementwiseFullLength = 302_893;
    private const double ElementwiseSentinel = -98_765.25d;

    // Signed zeros, subnormals and the smallest normal of both signs, and values on the common domain edges.
    private static readonly double[] ElementwiseSignedZeroValues =
    [
        0d, -0d, double.Epsilon, -double.Epsilon, 1e-310d, -1e-310d, 2.2250738585072014E-308d,
        -2.2250738585072014E-308d, 1d, -1d, 0.5d, 2d, 3d
    ];

    /// <summary>Gets every source identifier of the elementwise forms.</summary>
    public static TheoryData<string> ElementwiseSources => [.. SourceIdentifiers];

    /// <summary>
    /// Verifies every form and sibling on the regression sample, seeded arguments for every broadcast mask at
    /// n = 1, 2, 7 and 257 (two blocks), a fill equal to a computed value, every combination of signed zeros and
    /// subnormals, empty vectors, an empty vector next to a non-empty one, unequal lengths and invalid inputs.
    /// </summary>
    [Fact]
    [Trait("Category", "ElementwiseCuda")]
    public void CUDAElementwiseFormsMatchTheCoreCLRLiftOnSamplesAndEdgeCases()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var caseCount = 0;
        var invalidCount = 0;
        var filledRows = 0;
        foreach (var source in SourceIdentifiers)
        {
            foreach (var elementwiseCase in CreateElementwiseCases(source))
            {
                caseCount++;
                var coreclr = elementwiseCase.Operation.Evaluate(elementwiseCase.Inputs);
                if (!coreclr.IsValid)
                    invalidCount++;
                else if (coreclr.Type.Kind == MathBlockValueKind.BooleanVector)
                    filledRows += coreclr.AsBooleanVector().Count(value => !value);
                var cuda = ExecuteElementwiseCase(
                    worker,
                    elementwiseCase.Operation,
                    elementwiseCase.Prototype ?? elementwiseCase.Inputs,
                    elementwiseCase.Inputs);
                if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                    failures.Add($"{elementwiseCase.Operation.Identity}/{elementwiseCase.Name}: {difference}");
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(60)));
        Assert.True(caseCount >= 82 * 12, $"Only {caseCount} elementwise cases ran.");
        // Unequal lengths and invalid inputs make each form and sibling invalid at least twice.
        Assert.True(invalidCount >= 82 * 2, $"Only {invalidCount} elementwise cases were invalid.");
        Assert.True(filledRows > 1_000, $"Only {filledRows} source-invalid rows were compared.");
    }

    /// <summary>
    /// Verifies the form and sibling at the full PatternResearcher length of 302,893 rows for every broadcast mask
    /// against the CoreCLR lift, row for row.
    /// </summary>
    [Theory]
    [MemberData(nameof(ElementwiseSources))]
    [Trait("Category", "ElementwiseCudaFullScale")]
    public void CUDAElementwiseFormsMatchTheCoreCLRLiftAtFullLength(string source)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var computedRows = 0;
        foreach (var mask in BroadcastMasks(source))
        {
            var arguments = CreateArguments(source, ElementwiseFullLength, mask, 41_000 + mask);
            var formInputs = ElementwiseFormInputs(source, arguments, ElementwiseSentinel);
            MathBlockValue coreclrForm = default;
            MathBlockValue coreclrValidity = default;
            Parallel.Invoke(
                () => coreclrForm = Form(source).Evaluate(formInputs),
                () => coreclrValidity = Validity(source).Evaluate(arguments));
            var cudaForm = ExecuteElementwiseCase(worker, Form(source), formInputs, formInputs);
            var cudaValidity = ExecuteElementwiseCase(worker, Validity(source), arguments, arguments);
            var label = DescribeMask(source, mask);
            if (DescribeWindowDifference(coreclrForm, cudaForm) is { } formDifference)
                failures.Add($"elementwise.{source} [{label}]: {formDifference}");
            if (DescribeWindowDifference(coreclrValidity, cudaValidity) is { } validityDifference)
                failures.Add($"elementwise-valid.{source} [{label}]: {validityDifference}");
            if (coreclrValidity.IsValid)
                computedRows += coreclrValidity.AsBooleanVector().Count(value => value);
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
        Assert.True(computedRows > 0, $"{source}: the CoreCLR lift computed no row.");
    }

    /// <summary>
    /// Verifies CUDA scalar.clamp follows the Math.Clamp rule that CoreCLR uses: the 7 signed-zero cases where
    /// CUDA returned min(max(x, lower), upper) differ from it, more zero cases, and a lower limit above the upper
    /// limit, which is invalid on both sides.
    /// </summary>
    [Fact]
    [Trait("Category", "ElementwiseCuda")]
    public void CUDAClampFollowsTheMathClampRuleAtSignedZerosAndInvalidLimits()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        double[][] cases =
        [
            [-0d, 0d, 0d], [-0d, 0d, 1d], [-0d, 0d, 0.5d], [0d, 0d, -0d], [0d, -0d, -0d], [0d, -1d, -0d],
            [-1d, 0d, -0d], [-0d, -0d, 0d], [0d, -0d, 0d], [-1d, -0d, 0d], [1d, -0d, 0d], [-0d, -1d, 1d],
            [1d, 3d, 2d], [0d, 0d, -1d], [-0d, 1d, 0d], [5d, 2d, 2d]
        ];
        var clamp = MathBlockCatalog.Standard.Get("scalar.clamp");
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = Enumerable.Range(0, 3).Select(index => builder.Input($"input-{index}", MathBlockType.Scalar())).ToArray();
        var program = builder.Output("result", builder.Apply("scalar.clamp", 1, nodes)).Build();
        MathBlockValue[] prototype = [MathBlockValue.Scalar(5d), MathBlockValue.Scalar(0d), MathBlockValue.Scalar(3d)];
        using var compiled = new MathBlocksCUDAWorker().Compile(program, NameWindowInputs(prototype));
        var failures = new List<string>();
        var invalid = 0;
        foreach (var item in cases)
        {
            var inputs = item.Select(value => MathBlockValue.Scalar(value)).ToArray();
            var coreclr = clamp.Evaluate(inputs);
            compiled.UploadInputs(NameWindowInputs(inputs));
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];
            if (!coreclr.IsValid)
                invalid++;
            if (!IsExact(coreclr, cuda))
                failures.Add($"({string.Join(", ", inputs.Select(DescribeBits))}): CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
        }

        Assert.True(failures.Count == 0, $"{failures.Count} of {cases.Length} clamp cases differ: {string.Join("; ", failures)}");
        Assert.Equal(3, invalid);
    }

    /// <summary>
    /// Verifies the scalar operations built on the Lanczos log-gamma give the CoreCLR bits on CUDA on dense grids of
    /// non-integer, non-dyadic arguments (offsets of 0.1 and 0.3, so the shifts round): log-gamma on (0, 10] in
    /// steps of 1/64 and on the reflection branch (-3, 0.5), beta on a 40 x 40 grid of (0, 10] and pairs with one
    /// argument in (-3, 0.5), and the regularized incomplete beta on a grid of x in (0, 1) and parameters in
    /// (0, 10], plus parameters that are subnormal, where the exponential of the front factor is subnormal.
    /// </summary>
    [Theory]
    [InlineData("special.log-gamma")]
    [InlineData("special.beta")]
    [InlineData("special.regularized-incomplete-beta")]
    public void CUDALogGammaOperationsMatchCoreCLRBitForBitAtNonIntegerArguments(string identifier)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var cases = new List<MathBlockValue[]>();
        static MathBlockValue Scalar(double value) => MathBlockValue.Scalar(value);
        switch (operation.Arity)
        {
            case 1:
                for (var index = 0; index < 640; index++)
                    cases.Add([Scalar((index + 0.1d) / 64d)]);
                for (var index = 0; index < 224; index++)
                    cases.Add([Scalar(-3d + (index + 0.3d) / 64d)]);
                break;
            case 2:
                for (var left = 0; left < 40; left++)
                    for (var right = 0; right < 40; right++)
                        cases.Add([Scalar((left + 0.1d) / 4d), Scalar((right + 0.3d) / 4d)]);
                for (var index = 0; index < 224; index++)
                    cases.Add([Scalar(-3d + (index + 0.3d) / 64d), Scalar(1.7d + index / 32d)]);
                break;
            default:
                for (var x = 0; x < 10; x++)
                    for (var left = 0; left < 15; left++)
                        for (var right = 0; right < 15; right++)
                            cases.Add([Scalar((x + 0.5d) / 10d), Scalar((left + 0.5d) / 1.5d), Scalar((right + 0.3d) / 1.5d)]);
                foreach (var tiny in new[] { 5.86594004457162E-309d, 5.996723829767073E-309d, 1e-310d, 1.5e-308d })
                    for (var x = 0; x < 40; x++)
                        for (var left = 0; left < 5; left++)
                            cases.Add([Scalar((x + 0.5d) / 40d), Scalar((left + 0.3d) / 2d), Scalar(tiny)]);
                break;
        }
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = cases[0].Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program, NameWindowInputs(cases[0]));
        var failures = new List<string>();
        var valid = 0;
        for (var index = 0; index < cases.Count; index++)
        {
            var inputs = cases[index];
            var coreclr = operation.Evaluate(inputs);
            compiled.UploadInputs(NameWindowInputs(inputs));
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];
            if (coreclr.IsValid)
                valid++;
            if (!IsExact(coreclr, cuda))
                failures.Add($"({string.Join(", ", inputs.Select(DescribeBits))}): CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
        }

        Assert.True(
            failures.Count == 0,
            $"{identifier}: {failures.Count} of {cases.Count} cases differ. First 10: {string.Join("; ", failures.Take(10))}");
        Assert.True(valid > 600, $"{identifier}: only {valid} cases were valid.");
    }

    /// <summary>
    /// Verifies operations whose exponential result is subnormal give the CoreCLR bits on CUDA: the exponential
    /// and the logistic on 4,000 non-dyadic points of (-745.1, -707.6), the power of 0.5 to non-integer exponents in
    /// (1022, 1075), and the Poisson probability at rates in (708, 745).
    /// </summary>
    [Theory]
    [InlineData("scalar.exponential")]
    [InlineData("scalar.logistic")]
    [InlineData("scalar.power")]
    [InlineData("probability.poisson-pmf")]
    public void CUDASubnormalExponentialResultsMatchCoreCLRBitForBit(string identifier)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var cases = new List<MathBlockValue[]>();
        for (var index = 0; index < 4_000; index++)
        {
            var fraction = (index + 0.1d) / 4_000d;
            cases.Add(identifier switch
            {
                "scalar.power" => [MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(1022d + 53d * fraction)],
                "probability.poisson-pmf" => [MathBlockValue.Scalar(708d + 37d * fraction), MathBlockValue.Scalar(index % 4)],
                _ => [MathBlockValue.Scalar(-745.1d + 37.5d * fraction)]
            });
        }
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = cases[0].Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program, NameWindowInputs(cases[0]));
        var failures = new List<string>();
        var subnormal = 0;
        for (var index = 0; index < cases.Count; index++)
        {
            var inputs = cases[index];
            var coreclr = operation.Evaluate(inputs);
            compiled.UploadInputs(NameWindowInputs(inputs));
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];
            if (coreclr.IsValid && coreclr.AsScalar() != 0d && Math.Abs(coreclr.AsScalar()) < 2.2250738585072014E-308d)
                subnormal++;
            if (!IsExact(coreclr, cuda))
                failures.Add($"({string.Join(", ", inputs.Select(DescribeBits))}): CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
        }

        Assert.True(
            failures.Count == 0,
            $"{identifier}: {failures.Count} of {cases.Count} cases differ. First 10: {string.Join("; ", failures.Take(10))}");
        Assert.True(subnormal > 1_000, $"{identifier}: only {subnormal} results were subnormal.");
    }

    private static IEnumerable<ElementwiseCase> CreateElementwiseCases(string source)
    {
        var form = Form(source);
        var validity = Validity(source);
        yield return new ElementwiseCase("regression", form, form.RegressionCases[0].Inputs.ToArray());
        yield return new ElementwiseCase("regression", validity, validity.RegressionCases[0].Inputs.ToArray());
        foreach (var mask in BroadcastMasks(source))
        {
            var label = DescribeMask(source, mask);
            foreach (var count in new[] { 1, 2, 7, 257 })
            {
                var arguments = CreateArguments(source, count, mask, 9_000 + count * 8 + mask);
                yield return new ElementwiseCase($"[{label}] n={count}", form, ElementwiseFormInputs(source, arguments, ElementwiseSentinel));
                yield return new ElementwiseCase($"[{label}] n={count}", validity, arguments);
            }

            var seeded = CreateArguments(source, 257, mask, 9_500 + mask);
            var computed = form.Evaluate(ElementwiseFormInputs(source, seeded, ElementwiseSentinel));
            var realValue = computed.IsValid
                ? computed.AsVector().FirstOrDefault(value => value != ElementwiseSentinel, 0.25d)
                : 0.25d;
            yield return new ElementwiseCase($"[{label}] fill equal to a computed value", form, ElementwiseFormInputs(source, seeded, realValue));

            var signedZeros = CreateSignedZeroArguments(source, mask);
            yield return new ElementwiseCase($"[{label}] signed zeros", form, ElementwiseFormInputs(source, signedZeros, ElementwiseSentinel));
            yield return new ElementwiseCase($"[{label}] signed zeros", validity, signedZeros);

            var empty = ReplaceVectors(seeded, (_, _) => []);
            yield return new ElementwiseCase($"[{label}] empty", form, ElementwiseFormInputs(source, empty, ElementwiseSentinel));
            yield return new ElementwiseCase($"[{label}] empty", validity, empty);

            var vectorCount = Enumerable.Range(0, seeded.Length).Count(index => (mask >> index & 1) != 0);
            if (vectorCount < 2)
                continue;
            var firstVector = Array.FindIndex(seeded, argument => argument.Type.Kind == MathBlockValueKind.Vector);
            var emptyFirst = ReplaceVectors(seeded, (index, values) => index == firstVector ? [] : values);
            yield return new ElementwiseCase($"[{label}] empty next to non-empty", form, ElementwiseFormInputs(source, emptyFirst, ElementwiseSentinel));
            yield return new ElementwiseCase($"[{label}] empty next to non-empty", validity, emptyFirst);
            var unequal = ReplaceVectors(seeded, (index, values) => index == firstVector ? values[..^1] : values);
            yield return new ElementwiseCase($"[{label}] unequal lengths", form, ElementwiseFormInputs(source, unequal, ElementwiseSentinel));
            yield return new ElementwiseCase($"[{label}] unequal lengths", validity, unequal);
        }

        // An invalid vector argument and an invalid fill give an invalid result of the form's type. The program is
        // compiled from the valid arguments, which fix the capacities.
        var allVectors = CreateArguments(source, 7, (1 << SourceArity(source)) - 1, 9_900);
        var validForm = ElementwiseFormInputs(source, allVectors, ElementwiseSentinel);
        var invalidVector = (MathBlockValue[])allVectors.Clone();
        invalidVector[0] = MathBlockValue.Invalid(allVectors[0].Type, "Invalid elementwise argument.");
        yield return new ElementwiseCase("invalid vector argument", form, ElementwiseFormInputs(source, invalidVector, ElementwiseSentinel), validForm);
        yield return new ElementwiseCase("invalid vector argument", validity, invalidVector, allVectors);
        var invalidFill = (MathBlockValue[])validForm.Clone();
        invalidFill[^1] = MathBlockValue.Invalid(invalidFill[^1].Type, "Invalid fill.");
        yield return new ElementwiseCase("invalid fill", form, invalidFill, validForm);
    }

    // Vector arguments hold every combination of the signed-zero values across the vector positions; scalar
    // arguments take the value at the case index (cycling), so each mask sees zeros of both signs.
    private static MathBlockValue[] CreateSignedZeroArguments(string source, int mask)
    {
        var arity = SourceArity(source);
        var vectorIndexes = Enumerable.Range(0, arity).Where(index => (mask >> index & 1) != 0).ToArray();
        var count = 1;
        foreach (var _ in vectorIndexes)
            count *= ElementwiseSignedZeroValues.Length;
        var arguments = new MathBlockValue[arity];
        var scalarOrdinal = mask;
        for (var index = 0; index < arity; index++)
        {
            var position = Array.IndexOf(vectorIndexes, index);
            if (position < 0)
            {
                arguments[index] = MathBlockValue.Scalar(ElementwiseSignedZeroValues[scalarOrdinal++ % 2]);
                continue;
            }
            var values = new double[count];
            var stride = 1;
            for (var previous = 0; previous < position; previous++)
                stride *= ElementwiseSignedZeroValues.Length;
            for (var row = 0; row < count; row++)
                values[row] = ElementwiseSignedZeroValues[row / stride % ElementwiseSignedZeroValues.Length];
            arguments[index] = MathBlockValue.Vector(values);
        }
        return arguments;
    }

    private static MathBlockValue[] ReplaceVectors(MathBlockValue[] arguments, Func<int, double[], double[]> replace)
    {
        var result = new MathBlockValue[arguments.Length];
        for (var index = 0; index < arguments.Length; index++)
        {
            result[index] = arguments[index].Type.Kind == MathBlockValueKind.Vector
                ? MathBlockValue.Vector(replace(index, arguments[index].AsVector().ToArray()), arguments[index].Type.Unit)
                : arguments[index];
        }
        return result;
    }

    private static MathBlockValue[] ElementwiseFormInputs(string source, MathBlockValue[] arguments, double fill)
    {
        var unit = Form(source).ResolveOutputType([.. arguments.Select(argument => argument.Type), MathBlockType.Scalar()]).Unit;
        return [.. arguments, MathBlockValue.Scalar(fill, unit)];
    }

    // Compiles the operation with the prototype inputs (which set the capacities) and runs it on the inputs.
    private static MathBlockValue ExecuteElementwiseCase(
        MathBlocksCUDAWorker worker,
        MathBlockOperation operation,
        MathBlockValue[] prototype,
        MathBlockValue[] inputs)
    {
        var builder = new MathBlockProgramBuilder(MathBlockWindowTestSupport.Cuda);
        var nodes = prototype.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        using var compiled = worker.Compile(program, NameWindowInputs(prototype));
        return compiled.Execute(NameWindowInputs(inputs))["result"];
    }

    private sealed record ElementwiseCase(
        string Name,
        MathBlockOperation Operation,
        MathBlockValue[] Inputs,
        MathBlockValue[]? Prototype = null);
}
