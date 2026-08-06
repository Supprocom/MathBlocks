using System.Runtime.InteropServices;
using System.Text;
using Supprocom.MathBlocks;
using Supprocom.MathBlocks.Cuda;
using Complex = Supprocom.MathBlocks.MathBlockComplexValue;

namespace Supprocom.MathBlocks.ExternalConsumer;

internal static class Program
{
    private const int Alignment = 16;
    private const int MaximumArity = 8;

    private static unsafe int Main()
    {
        var contracts = MathBlockCudaDeviceModule.Operations;
        Require(contracts.Count == 337, "The external contract must contain 337 operations.");
        Require(
            contracts.Select(contract => contract.Identity).SequenceEqual(
                MathBlockCatalog.Standard.Operations.Select(operation => operation.Identity)),
            "The CPU and CUDA operation identities differ.");
        Require(
            contracts.All(contract => contract.Arity <= MaximumArity),
            "An operation exceeds the external kernel arity.");
        Require(
            Enum.GetValues<MathBlockCudaOperationFamily>()
                .All(family => contracts.Any(contract => contract.Family == family)),
            "The external contract does not contain each CUDA family.");

        var cases = contracts.Select(CreateCase).ToArray();
        var nested = CreateNestedLayout(cases.Sum(item => item.Inputs.Length + 1));
        var descriptorBytes = checked(cases.Length * sizeof(OperationDescriptor));
        var slotCount = checked(nested.OutputSlot + 1);
        var slotBaseOffset = Align(descriptorBytes);
        var cursor = checked(slotBaseOffset + slotCount * MathBlockCudaSlotLayout.Size);

        foreach (var item in cases)
        {
            for (var index = 0; index < item.Inputs.Length; index++)
            {
                var input = item.Inputs[index];
                var bytes = MathBlockCudaValueCodec.GetPayloadByteCount(
                    input.Value.Type.Kind,
                    input.Capacity);
                input.PayloadOffset = Allocate(ref cursor, bytes);
            }

            var outputBytes = MathBlockCudaValueCodec.GetPayloadByteCount(
                item.Plan.OutputType.Kind,
                item.Plan.OutputCapacity);
            item.OutputPayloadOffset = Allocate(ref cursor, outputBytes);
            item.ScratchOffset = Allocate(ref cursor, item.Plan.ScratchBytes);
        }

        var arenaBytes = Align(cursor);
        var hostArena = Marshal.AllocHGlobal(arenaBytes);
        var deviceArena = 0ul;
        var module = IntPtr.Zero;
        var stream = IntPtr.Zero;
        var kernelArguments = IntPtr.Zero;
        var argumentValues = Array.Empty<IntPtr>();
        try
        {
            new Span<byte>((void*)hostArena, arenaBytes).Clear();
            CudaDriver.Initialize();
            CudaDriver.Require(
                CudaDriver.cuMemAlloc(out deviceArena, new UIntPtr(checked((uint)arenaBytes))),
                "cuMemAlloc(external arena)");
            WriteArena(hostArena, deviceArena, slotBaseOffset, cases, nested);
            CudaDriver.Require(
                CudaDriver.cuMemcpyHtoD(
                    deviceArena,
                    hostArena,
                    new UIntPtr(checked((uint)arenaBytes))),
                "cuMemcpyHtoD(external arena)");

            var source = CreateKernelSource(cases.Length, nested);
            var ptx = MathBlockCudaDeviceModule.CompilePtx(source, "mathblocks-external-consumer.cu");
            CudaDriver.Require(CudaDriver.cuModuleLoadData(out module, ptx), "cuModuleLoadData");
            CudaDriver.Require(
                CudaDriver.cuModuleGetFunction(out var function, module, "external_operation_contract"),
                "cuModuleGetFunction(external_operation_contract)");
            CudaDriver.Require(CudaDriver.cuStreamCreate(out stream, 1), "cuStreamCreate");

            (kernelArguments, argumentValues) = CreateKernelArguments(
                deviceArena,
                cases.Length,
                checked(deviceArena + (ulong)slotBaseOffset));
            CudaDriver.Require(
                CudaDriver.cuLaunchKernel(
                    function,
                    checked((uint)cases.Length + 1u),
                    1,
                    1,
                    MathBlockCudaDeviceModule.DispatcherBlockSize,
                    1,
                    1,
                    0,
                    stream,
                    kernelArguments,
                    IntPtr.Zero),
                "cuLaunchKernel(external_operation_contract)");
            CudaDriver.Require(CudaDriver.cuStreamSynchronize(stream), "cuStreamSynchronize");
            CudaDriver.Require(
                CudaDriver.cuMemcpyDtoH(
                    hostArena,
                    deviceArena,
                    new UIntPtr(checked((uint)arenaBytes))),
                "cuMemcpyDtoH(external arena)");

            var failures = ReadAndCompare(hostArena, slotBaseOffset, cases, nested);
            Require(failures.Count == 0, string.Join(Environment.NewLine, failures));
            Require(
                !MathBlockCudaDeviceModule.Source.Contains("PopulationSearch", StringComparison.Ordinal),
                "The device module contains search orchestration.");

            Console.WriteLine($"operations={cases.Length}");
            Console.WriteLine($"families={Enum.GetValues<MathBlockCudaOperationFamily>().Length}");
            Console.WriteLine($"abi={MathBlockCudaDeviceModule.AbiFingerprint}");
            Console.WriteLine($"arena-bytes={arenaBytes}");
            Console.WriteLine("uploads=1");
            Console.WriteLine("launches=1");
            Console.WriteLine("synchronizations=1");
            Console.WriteLine("downloads=1");
            Console.WriteLine("search-orchestration=0");
            Console.WriteLine("status=passed");
            return 0;
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine(exception);
            return 1;
        }
        finally
        {
            foreach (var value in argumentValues)
                if (value != IntPtr.Zero)
                    Marshal.FreeHGlobal(value);
            if (kernelArguments != IntPtr.Zero)
                Marshal.FreeHGlobal(kernelArguments);
            if (stream != IntPtr.Zero)
                _ = CudaDriver.cuStreamDestroy(stream);
            if (module != IntPtr.Zero)
                _ = CudaDriver.cuModuleUnload(module);
            if (deviceArena != 0ul)
                _ = CudaDriver.cuMemFree(deviceArena);
            Marshal.FreeHGlobal(hostArena);
        }
    }

    private static OperationCase CreateCase(MathBlockCudaOperationContract contract)
    {
        var regression = contract.RegressionCases[0];
        var plan = contract.PlanCUDA(regression.Inputs);
        var expected = contract.EvaluateCPU(regression.Inputs);
        Require(
            plan.OutputType.Accepts(expected.Type),
            $"The output type plan failed for '{contract.Identity}'.");
        var inputs = new InputLayout[regression.Inputs.Count];
        for (var index = 0; index < inputs.Length; index++)
        {
            var input = regression.Inputs[index];
            inputs[index] = new InputLayout(
                input,
                MathBlockCudaValueCodec.GetElementCount(input));
        }
        return new OperationCase(contract, plan, expected, inputs);
    }

    private static NestedLayout CreateNestedLayout(int firstSlot)
    {
        var add = MathBlockCudaDeviceModule.GetOperation("scalar.add@1");
        var multiply = MathBlockCudaDeviceModule.GetOperation("scalar.multiply@1");
        return new NestedLayout(
            add,
            multiply,
            firstSlot,
            firstSlot + 1,
            firstSlot + 2,
            firstSlot + 3,
            firstSlot + 4);
    }

    private static int Allocate(ref int cursor, int bytes)
    {
        if (bytes == 0)
            return -1;
        cursor = Align(cursor);
        var offset = cursor;
        cursor = checked(cursor + bytes);
        return offset;
    }

    private static int Align(int value) => checked((value + Alignment - 1) & -Alignment);

    private static unsafe void WriteArena(
        IntPtr arena,
        ulong deviceArena,
        int slotBaseOffset,
        IReadOnlyList<OperationCase> cases,
        NestedLayout nested)
    {
        var nextSlot = 0;
        for (var caseIndex = 0; caseIndex < cases.Count; caseIndex++)
        {
            var item = cases[caseIndex];
            item.FirstInputSlot = nextSlot;
            for (var inputIndex = 0; inputIndex < item.Inputs.Length; inputIndex++)
            {
                var input = item.Inputs[inputIndex];
                var slotOffset = SlotOffset(slotBaseOffset, nextSlot++);
                var payloadPointer = input.PayloadOffset < 0
                    ? 0ul
                    : checked(deviceArena + (ulong)input.PayloadOffset);
                MathBlockCudaValueCodec.WriteValue(
                    arena,
                    slotOffset,
                    input.PayloadOffset,
                    payloadPointer,
                    0ul,
                    input.Capacity,
                    input.Value);
            }

            item.OutputSlot = nextSlot++;
            var outputSlotOffset = SlotOffset(slotBaseOffset, item.OutputSlot);
            var outputPointer = item.OutputPayloadOffset < 0
                ? 0ul
                : checked(deviceArena + (ulong)item.OutputPayloadOffset);
            var scratchPointer = item.ScratchOffset < 0
                ? 0ul
                : checked(deviceArena + (ulong)item.ScratchOffset);
            var layoutType = new MathBlockType(
                item.Plan.OutputType.Kind,
                item.Plan.OutputType.Unit,
                item.Plan.OutputRows,
                item.Plan.OutputColumns);
            MathBlockCudaValueCodec.WriteHeader(
                arena,
                outputSlotOffset,
                outputPointer,
                scratchPointer,
                item.Plan.OutputCapacity,
                layoutType,
                valid: false);

            *(OperationDescriptor*)((byte*)arena + caseIndex * sizeof(OperationDescriptor)) =
                new OperationDescriptor
                {
                    Family = (int)item.Contract.Family,
                    Opcode = item.Contract.Opcode,
                    FirstInputSlot = item.FirstInputSlot,
                    InputCount = item.Inputs.Length,
                    OutputSlot = item.OutputSlot
                };
        }

        Require(nextSlot == nested.FirstInputSlot, "The nested slot boundary differs.");
        WriteScalar(arena, deviceArena, slotBaseOffset, nested.FirstInputSlot, 6d);
        WriteScalar(arena, deviceArena, slotBaseOffset, nested.SecondInputSlot, 2d);
        MathBlockCudaValueCodec.WriteHeader(
            arena,
            SlotOffset(slotBaseOffset, nested.AddOutputSlot),
            0ul,
            0ul,
            0,
            MathBlockType.Scalar(),
            valid: false);
        WriteScalar(arena, deviceArena, slotBaseOffset, nested.MultiplierSlot, 4d);
        MathBlockCudaValueCodec.WriteHeader(
            arena,
            SlotOffset(slotBaseOffset, nested.OutputSlot),
            0ul,
            0ul,
            0,
            MathBlockType.Scalar(),
            valid: false);
    }

    private static void WriteScalar(
        IntPtr arena,
        ulong deviceArena,
        int slotBaseOffset,
        int slot,
        double value)
    {
        _ = deviceArena;
        MathBlockCudaValueCodec.WriteValue(
            arena,
            SlotOffset(slotBaseOffset, slot),
            -1,
            0ul,
            0ul,
            0,
            MathBlockValue.Scalar(value));
    }

    private static int SlotOffset(int slotBaseOffset, int slot) =>
        checked(slotBaseOffset + slot * MathBlockCudaSlotLayout.Size);

    private static string CreateKernelSource(int operationCount, NestedLayout nested)
    {
        return $$"""
            struct ExternalOperationDescriptor
            {
                int family;
                int opcode;
                int first_input_slot;
                int input_count;
                int output_slot;
            };

            extern "C" __global__ void external_operation_contract(
                const ExternalOperationDescriptor* operations,
                int operation_count,
                MathBlockSlot* slots)
            {
                int ordinal = (int)blockIdx.x;
                if (ordinal < operation_count)
                {
                    ExternalOperationDescriptor operation = operations[ordinal];
                    const MathBlockSlot* inputs[{{MaximumArity}}];
                    for (int index = 0; index < operation.input_count; ++index)
                        inputs[index] = &slots[operation.first_input_slot + index];
                    mathblocks_operation_dispatch(
                        operation.family,
                        operation.opcode,
                        inputs,
                        operation.input_count,
                        &slots[operation.output_slot]);
                    return;
                }

                if (ordinal != operation_count)
                    return;
                const MathBlockSlot* add_inputs[2] =
                {
                    &slots[{{nested.FirstInputSlot}}],
                    &slots[{{nested.SecondInputSlot}}]
                };
                mathblocks_operation_dispatch(
                    {{(int)nested.Add.Family}},
                    {{nested.Add.Opcode}},
                    add_inputs,
                    2,
                    &slots[{{nested.AddOutputSlot}}]);
                const MathBlockSlot* multiply_inputs[2] =
                {
                    &slots[{{nested.AddOutputSlot}}],
                    &slots[{{nested.MultiplierSlot}}]
                };
                mathblocks_operation_dispatch(
                    {{(int)nested.Multiply.Family}},
                    {{nested.Multiply.Opcode}},
                    multiply_inputs,
                    2,
                    &slots[{{nested.OutputSlot}}]);
            }
            """;
    }

    private static (IntPtr PointerArray, IntPtr[] Values) CreateKernelArguments(
        ulong operations,
        int operationCount,
        ulong slots)
    {
        var values = new[]
        {
            AllocateUInt64(operations),
            AllocateInt32(operationCount),
            AllocateUInt64(slots)
        };
        var pointers = Marshal.AllocHGlobal(checked(values.Length * IntPtr.Size));
        for (var index = 0; index < values.Length; index++)
            Marshal.WriteIntPtr(pointers, index * IntPtr.Size, values[index]);
        return (pointers, values);
    }

    private static IntPtr AllocateUInt64(ulong value)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(ulong));
        Marshal.WriteInt64(pointer, unchecked((long)value));
        return pointer;
    }

    private static IntPtr AllocateInt32(int value)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(int));
        Marshal.WriteInt32(pointer, value);
        return pointer;
    }

    private static List<string> ReadAndCompare(
        IntPtr arena,
        int slotBaseOffset,
        IReadOnlyList<OperationCase> cases,
        NestedLayout nested)
    {
        var failures = new List<string>();
        foreach (var item in cases)
        {
            var actual = MathBlockCudaValueCodec.ReadValue(
                arena,
                SlotOffset(slotBaseOffset, item.OutputSlot),
                item.OutputPayloadOffset,
                item.Plan.OutputType);
            if (!IsExact(item.Expected, actual))
            {
                failures.Add(
                    $"{item.Contract.Identity}: CPU={Describe(item.Expected)}, CUDA={Describe(actual)}");
            }
        }

        var nestedOutput = MathBlockCudaValueCodec.ReadValue(
            arena,
            SlotOffset(slotBaseOffset, nested.OutputSlot),
            -1,
            MathBlockType.Scalar());
        if (!nestedOutput.IsValid ||
            BitConverter.DoubleToInt64Bits(nestedOutput.AsScalar()) !=
            BitConverter.DoubleToInt64Bits(32d))
        {
            failures.Add($"nested-scalar-DAG: CUDA={Describe(nestedOutput)}");
        }
        return failures;
    }

    private static bool IsExact(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.Type != actual.Type || expected.IsValid != actual.IsValid)
            return false;
        if (!expected.IsValid)
            return true;
        return expected.Type.Kind switch
        {
            MathBlockValueKind.Scalar => ExactDouble(expected.AsScalar(), actual.AsScalar()),
            MathBlockValueKind.Boolean => expected.AsBoolean() == actual.AsBoolean(),
            MathBlockValueKind.Complex => ExactComplex(expected.AsComplex(), actual.AsComplex()),
            MathBlockValueKind.Vector => ExactDoubles(expected.AsVector(), actual.AsVector()),
            MathBlockValueKind.Matrix =>
                expected.AsMatrix().Rows == actual.AsMatrix().Rows &&
                expected.AsMatrix().Columns == actual.AsMatrix().Columns &&
                ExactDoubles(expected.AsMatrix().ToArray(), actual.AsMatrix().ToArray()),
            MathBlockValueKind.ComplexVector =>
                ExactComplexes(expected.AsComplexVector(), actual.AsComplexVector()),
            MathBlockValueKind.ComplexMatrix =>
                expected.AsComplexMatrix().Rows == actual.AsComplexMatrix().Rows &&
                expected.AsComplexMatrix().Columns == actual.AsComplexMatrix().Columns &&
                ExactComplexes(expected.AsComplexMatrix().ToArray(), actual.AsComplexMatrix().ToArray()),
            MathBlockValueKind.PointSet => ExactPoints(expected.AsPointSet(), actual.AsPointSet()),
            MathBlockValueKind.Graph => ExactGraphs(expected.AsGraph(), actual.AsGraph()),
            MathBlockValueKind.RunSet => ExactRuns(expected.AsRunSet(), actual.AsRunSet()),
            MathBlockValueKind.BooleanVector =>
                ExactBooleans(expected.AsBooleanVector(), actual.AsBooleanVector()),
            _ => false
        };
    }

    private static bool ExactDoubles(IReadOnlyList<double> expected, IReadOnlyList<double> actual) =>
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index => ExactDouble(expected[index], actual[index]));

    private static bool ExactBooleans(IReadOnlyList<bool> expected, IReadOnlyList<bool> actual) =>
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index => expected[index] == actual[index]);

    private static bool ExactComplex(Complex expected, Complex actual) =>
        ExactDouble(expected.Real, actual.Real) &&
        ExactDouble(expected.Imaginary, actual.Imaginary);

    private static bool ExactComplexes(IReadOnlyList<Complex> expected, IReadOnlyList<Complex> actual) =>
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index => ExactComplex(expected[index], actual[index]));

    private static bool ExactPoints(IReadOnlyList<MathBlockPoint> expected, IReadOnlyList<MathBlockPoint> actual) =>
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index =>
            ExactDouble(expected[index].X, actual[index].X) &&
            ExactDouble(expected[index].Y, actual[index].Y));

    private static bool ExactGraphs(MathBlockGraph expected, MathBlockGraph actual) =>
        expected.VertexCount == actual.VertexCount &&
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index =>
            expected[index].From == actual[index].From &&
            expected[index].To == actual[index].To &&
            ExactDouble(expected[index].Weight, actual[index].Weight));

    private static bool ExactRuns(IReadOnlyList<MathBlockRun> expected, IReadOnlyList<MathBlockRun> actual) =>
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index =>
            expected[index].Start == actual[index].Start &&
            expected[index].Length == actual[index].Length &&
            ExactDouble(expected[index].Value, actual[index].Value));

    private static bool ExactDouble(double expected, double actual) =>
        BitConverter.DoubleToInt64Bits(expected) == BitConverter.DoubleToInt64Bits(actual);

    private static string Describe(MathBlockValue value)
    {
        if (!value.IsValid)
            return "invalid";
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar =>
                $"{value.AsScalar():R}/0x{BitConverter.DoubleToInt64Bits(value.AsScalar()):x16}",
            MathBlockValueKind.Boolean => value.AsBoolean().ToString(),
            MathBlockValueKind.Vector =>
                $"[{string.Join(",", value.AsVector().Select(item =>
                    $"{item:R}/0x{BitConverter.DoubleToInt64Bits(item):x16}"))}]",
            MathBlockValueKind.BooleanVector => $"[{string.Join(",", value.AsBooleanVector())}]",
            _ => value.Type.ToString()
        };
    }

    private static void Require(bool condition, string message)
    {
        if (!condition)
            throw new InvalidOperationException(message);
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct OperationDescriptor
    {
        public int Family;
        public int Opcode;
        public int FirstInputSlot;
        public int InputCount;
        public int OutputSlot;
    }

    private sealed class InputLayout(MathBlockValue value, int capacity)
    {
        public MathBlockValue Value { get; } = value;
        public int Capacity { get; } = capacity;
        public int PayloadOffset { get; set; } = -1;
    }

    private sealed class OperationCase(
        MathBlockCudaOperationContract contract,
        MathBlockCudaOperationPlan plan,
        MathBlockValue expected,
        InputLayout[] inputs)
    {
        public MathBlockCudaOperationContract Contract { get; } = contract;
        public MathBlockCudaOperationPlan Plan { get; } = plan;
        public MathBlockValue Expected { get; } = expected;
        public InputLayout[] Inputs { get; } = inputs;
        public int FirstInputSlot { get; set; }
        public int OutputSlot { get; set; }
        public int OutputPayloadOffset { get; set; } = -1;
        public int ScratchOffset { get; set; } = -1;
    }

    private sealed record NestedLayout(
        MathBlockCudaOperationContract Add,
        MathBlockCudaOperationContract Multiply,
        int FirstInputSlot,
        int SecondInputSlot,
        int AddOutputSlot,
        int MultiplierSlot,
        int OutputSlot);

    private static class CudaDriver
    {
        static CudaDriver()
        {
            if (!OperatingSystem.IsWindows())
            {
                NativeLibrary.SetDllImportResolver(
                    typeof(CudaDriver).Assembly,
                    static (name, _, _) =>
                        string.Equals(name, "nvcuda.dll", StringComparison.Ordinal)
                            ? LoadCuda()
                            : IntPtr.Zero);
            }
        }

        public static void Initialize()
        {
            Require(cuInit(0), "cuInit");
            Require(cuDeviceGet(out var device, 0), "cuDeviceGet");
            Require(cuDevicePrimaryCtxRetain(out var context, device), "cuDevicePrimaryCtxRetain");
            Require(cuCtxSetCurrent(context), "cuCtxSetCurrent");
        }

        public static void Require(int result, string operation)
        {
            if (result != 0)
                throw new InvalidOperationException($"{operation} failed with CUDA result {result}.");
        }

        private static IntPtr LoadCuda()
        {
            if (NativeLibrary.TryLoad("libcuda.so.1", out var handle))
                return handle;
            return NativeLibrary.TryLoad("libcuda.so", out handle) ? handle : IntPtr.Zero;
        }

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuInit(uint flags);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuDeviceGet(out int device, int ordinal);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuDevicePrimaryCtxRetain(out IntPtr context, int device);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuCtxSetCurrent(IntPtr context);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuModuleLoadData(out IntPtr module, byte[] image);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern int cuModuleGetFunction(out IntPtr function, IntPtr module, string name);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuModuleUnload(IntPtr module);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemAlloc_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemAlloc(out ulong devicePointer, UIntPtr bytes);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemFree_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemFree(ulong devicePointer);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyHtoD_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemcpyHtoD(ulong destination, IntPtr source, UIntPtr bytes);

        [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyDtoH_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuMemcpyDtoH(IntPtr destination, ulong source, UIntPtr bytes);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuStreamCreate(out IntPtr stream, uint flags);

        [DllImport("nvcuda.dll", EntryPoint = "cuStreamDestroy_v2", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuStreamDestroy(IntPtr stream);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuStreamSynchronize(IntPtr stream);

        [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int cuLaunchKernel(
            IntPtr function,
            uint gridX,
            uint gridY,
            uint gridZ,
            uint blockX,
            uint blockY,
            uint blockZ,
            uint sharedMemoryBytes,
            IntPtr stream,
            IntPtr kernelParameters,
            IntPtr extra);
    }
}
