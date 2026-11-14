using System.Diagnostics;
using System.Globalization;
using System.Reflection;
using System.Reflection.Emit;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains regression tests for the definition of the value codec implementation fingerprint: it hashes the
/// resolved IL of the codec, so an unrelated change in the assembly or a different assembly version leaves it alone.
/// The internal hashing types are reached by name through reflection, because the library exposes no internals.
/// </summary>
public sealed class MathBlockCudaImplementationFingerprintTests
{
    // The pins of a Release build of this library. A Debug build compiles different IL, so the pin test asserts only
    // in an optimized assembly.
    private const string ReleaseCodecImplementationFingerprint =
        "286E0256EC1A4AE0355BE9DC542E1EB97389FD1053D4CFCE7E775DC0E8D7275A";
    private const string ReleaseDeviceAbiFingerprint =
        "192FE472E59928550614ECC2DF0EE93349B762709B115D25BA34DE1FBE251545";

    // Resolved lazily by name and allowed to be absent, so that this class also compiles and runs against a library
    // that has the older definition: the tests that need the new writer then fail on their own.
    private static readonly Type? CanonicalIlType = typeof(MathBlockCudaValueCodec).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaCanonicalIl", throwOnError: false);

    private static readonly Type ContractHashType = typeof(MathBlockCudaValueCodec).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaContractHash", throwOnError: true)!;

    /// <summary>Verifies the codec material holds no assembly version, metadata token or heap offset.</summary>
    [Fact]
    public void ImplementationMaterialHoldsNoAssemblyVersionAndNoRawMetadataToken()
    {
        var codecAssembly = typeof(MathBlockCudaValueCodec).Assembly;
        var material = CreateMaterial(typeof(MathBlockCudaValueCodec));

        Assert.StartsWith("mathblocks-managed-implementation-v2\n", material, StringComparison.Ordinal);
        Assert.DoesNotContain("Version=", material, StringComparison.Ordinal);
        Assert.DoesNotContain("Culture=", material, StringComparison.Ordinal);
        Assert.DoesNotContain("PublicKeyToken", material, StringComparison.Ordinal);
        Assert.DoesNotContain(codecAssembly.FullName!, material, StringComparison.Ordinal);
        Assert.DoesNotContain(codecAssembly.GetName().Version!.ToString(), material, StringComparison.Ordinal);
        foreach (var line in material.Split('\n'))
        {
            // A raw IL dump is one long line of hexadecimal digits; a resolved instruction names its opcode first.
            Assert.False(IsHexadecimalRun(line), "The material holds a raw hexadecimal line: " + line);
        }

        Assert.Contains(
            "\nGetPayloadByteCount(Supprocom.MathBlocks.MathBlockValueKind,System.Int32)->System.Int32\n",
            material,
            StringComparison.Ordinal);
        Assert.Equal(material, CreateMaterial(typeof(MathBlockCudaValueCodec)));
    }

    /// <summary>Verifies every kind of IL token resolves to the name of the member, type or string it stands for.</summary>
    [Fact]
    public void ImplementationMaterialResolvesEveryTokenToItsName()
    {
        var probe = typeof(TokenProbe).FullName;
        var material = CreateMaterial(typeof(TokenProbe));

        Assert.Contains("\nldstr S:14:probe-literal:\n", material, StringComparison.Ordinal);
        Assert.Contains("\nldsfld F:" + probe + "::Counter:System.Int32\n", material, StringComparison.Ordinal);
        Assert.Contains("\nstsfld F:" + probe + "::Counter:System.Int32\n", material, StringComparison.Ordinal);
        Assert.Contains(
            "\nnewobj M:System.Collections.Generic.List`1<System.Int32>::.ctor()\n",
            material,
            StringComparison.Ordinal);
        Assert.Contains(
            "\ncallvirt M:System.Collections.Generic.List`1<System.Int32>::Add(System.Int32)->System.Void\n",
            material,
            StringComparison.Ordinal);
        Assert.Contains("\nnewarr T:System.Int64\n", material, StringComparison.Ordinal);
        Assert.Contains("\ncastclass T:System.String\n", material, StringComparison.Ordinal);
        Assert.Contains(
            "\ncall M:" + probe + "::Helper(System.Int32)->System.String\n",
            material,
            StringComparison.Ordinal);
        Assert.Contains("\nlocal:", material, StringComparison.Ordinal);
        Assert.DoesNotContain("Version=", material, StringComparison.Ordinal);
    }

    /// <summary>Verifies type names carry no assembly version, culture or public key token.</summary>
    [Fact]
    public void TypeNamesCarryNoAssemblyQualifier()
    {
        Assert.Equal("System.Int32", CreateTypeName(typeof(int)));
        Assert.Equal("System.Int32[]", CreateTypeName(typeof(int[])));
        Assert.Equal("System.Int32[,]", CreateTypeName(typeof(int[,])));
        Assert.Equal("System.Int32&", CreateTypeName(typeof(int).MakeByRefType()));
        Assert.Equal("System.Int32*", CreateTypeName(typeof(int).MakePointerType()));
        Assert.Equal(
            "System.Collections.Generic.Dictionary`2<System.String,System.Collections.Generic.List`1<System.Int32>[]>",
            CreateTypeName(typeof(Dictionary<string, List<int>[]>)));
        Assert.Equal("System.Nullable`1<System.Int32>", CreateTypeName(typeof(int?)));
        Assert.Equal("!0", CreateTypeName(typeof(List<>).GetGenericArguments()[0]));
        Assert.Equal(
            "Supprocom.MathBlocks.Cuda.MathBlockCudaValueCodec",
            CreateTypeName(typeof(MathBlockCudaValueCodec)));
        Assert.Equal(
            typeof(MathBlockCudaImplementationFingerprintTests).FullName + "+TokenProbe",
            CreateTypeName(typeof(TokenProbe)));
    }

    /// <summary>Verifies the fingerprint ignores an unrelated change in the assembly and the assembly version.</summary>
    [Fact]
    public void ImplementationFingerprintIgnoresUnrelatedMembersAndTheAssemblyVersion()
    {
        var baseline = EmitProbe(new ProbeShape(new Version(0, 7, 0, 0), 0, "probe-literal", TrimEnd: true));
        var shifted = EmitProbe(new ProbeShape(new Version(0, 6, 1, 0), 3, "probe-literal", TrimEnd: true));
        var bumped = EmitProbe(new ProbeShape(new Version(9, 8, 7, 6), 1, "probe-literal", TrimEnd: true));

        // The unrelated types shift the metadata rows and the user-string heap offsets that the raw IL names.
        Assert.NotEqual(RawIl(baseline, "Run"), RawIl(shifted, "Run"), StringComparer.Ordinal);
        Assert.NotEqual(RawIl(baseline, "Run"), RawIl(bumped, "Run"), StringComparer.Ordinal);
        Assert.NotEqual(RawIl(shifted, "Run"), RawIl(bumped, "Run"), StringComparer.Ordinal);
        Assert.NotEqual(baseline.Assembly.GetName().Version, shifted.Assembly.GetName().Version);

        var expected = CreateImplementation(baseline);
        Assert.Equal(64, expected.Length);
        Assert.Equal(expected, CreateImplementation(shifted));
        Assert.Equal(expected, CreateImplementation(bumped));
        Assert.Equal(CreateMaterial(baseline), CreateMaterial(shifted));
    }

    /// <summary>Verifies the fingerprint follows a changed string, a changed call target and a changed body.</summary>
    [Fact]
    public void ImplementationFingerprintFollowsWhatTheMethodsDo()
    {
        var baseline = CreateImplementation(
            EmitProbe(new ProbeShape(new Version(0, 7, 0, 0), 2, "probe-literal", TrimEnd: true)));

        var otherString = CreateImplementation(
            EmitProbe(new ProbeShape(new Version(0, 7, 0, 0), 2, "probe-literal2", TrimEnd: true)));
        var otherCallee = CreateImplementation(
            EmitProbe(new ProbeShape(new Version(0, 7, 0, 0), 2, "probe-literal", TrimEnd: false)));
        var otherBody = CreateImplementation(
            EmitProbe(new ProbeShape(new Version(0, 7, 0, 0), 2, "probe-literal", TrimEnd: true, Addend: 2)));

        Assert.NotEqual(baseline, otherString, StringComparer.Ordinal);
        Assert.NotEqual(baseline, otherCallee, StringComparer.Ordinal);
        Assert.NotEqual(baseline, otherBody, StringComparer.Ordinal);
        Assert.NotEqual(otherString, otherCallee, StringComparer.Ordinal);
    }

    /// <summary>Verifies an indirect call through a function pointer is written with its signature and no token.</summary>
    [Fact]
    public void ImplementationMaterialWritesFunctionPointerCallsWithoutTokens()
    {
        var material = CreateMaterial(typeof(FunctionPointerProbe));

        Assert.Contains("\ncalli SIG:Default generic=0 required=1 (Int32)->Int32\n", material, StringComparison.Ordinal);
        Assert.Contains(
            "\nInvoke(fnptr(System.Int32)->System.Int32,System.Int32)->System.Int32\n",
            material,
            StringComparison.Ordinal);
        Assert.DoesNotContain("Version=", material, StringComparison.Ordinal);
    }

    /// <summary>Verifies an exception clause and a call to a method of the same type are written by name.</summary>
    [Fact]
    public void ImplementationMaterialWritesExceptionClausesAndSameTypeCallsByName()
    {
        var material = CreateMaterial(
            EmitProbe(new ProbeShape(new Version(0, 7, 0, 0), 2, "probe-literal", TrimEnd: true)));

        Assert.Contains("\ncall M:Probe.Codec::Helper(System.Int32)->System.Int32\n", material, StringComparison.Ordinal);
        Assert.Contains("\nldsfld F:Probe.Codec::Counter:System.Int32\n", material, StringComparison.Ordinal);
        Assert.Contains("\nclause:", material, StringComparison.Ordinal);
        Assert.EndsWith(
            ":System.InvalidOperationException\n",
            material[material.IndexOf("\nclause:", StringComparison.Ordinal)..].Split('\n')[1] + "\n",
            StringComparison.Ordinal);
        Assert.DoesNotContain("Version=", material, StringComparison.Ordinal);
    }

    /// <summary>Verifies the codec fingerprint and the device ABI fingerprint of a Release build.</summary>
    [Fact]
    public void ImplementationAndDeviceAbiFingerprintsMatchTheReleasePins()
    {
        var abi = MathBlockCudaDeviceModule.Abi;
        Assert.Equal(MathBlockCudaValueCodec.ImplementationFingerprint, abi.ValueCodecImplementationFingerprint);
        Assert.Equal(
            MathBlockCudaValueCodec.ImplementationFingerprint,
            CreateImplementation(typeof(MathBlockCudaValueCodec)));
        Assert.Equal(MathBlockCudaDeviceModule.AbiFingerprint, abi.Fingerprint);

        var debuggable = typeof(MathBlockCudaValueCodec).Assembly.GetCustomAttribute<DebuggableAttribute>();
        if (debuggable is { IsJITOptimizerDisabled: true })
            return;
        Assert.True(
            string.Equals(
                ReleaseCodecImplementationFingerprint,
                MathBlockCudaValueCodec.ImplementationFingerprint,
                StringComparison.Ordinal),
            "The value codec implementation fingerprint is " + MathBlockCudaValueCodec.ImplementationFingerprint);
        Assert.True(
            string.Equals(
                ReleaseDeviceAbiFingerprint,
                MathBlockCudaDeviceModule.AbiFingerprint,
                StringComparison.Ordinal),
            "The device ABI fingerprint is " + MathBlockCudaDeviceModule.AbiFingerprint);
    }

    private static bool IsHexadecimalRun(string line)
    {
        var start = line.StartsWith("il:", StringComparison.Ordinal) ? 3 : 0;
        if (line.Length - start < 16)
            return false;
        for (var index = start; index < line.Length; index++)
        {
            if (!char.IsAsciiHexDigitUpper(line[index]))
                return false;
        }

        return true;
    }

    private static string CreateMaterial(Type type) =>
        (string)RequireCanonicalIl().GetMethod("CreateImplementationMaterial", BindingFlags.Public | BindingFlags.Static)!
            .Invoke(null, [type])!;

    private static string CreateTypeName(Type type) =>
        (string)RequireCanonicalIl().GetMethod("CreateTypeName", BindingFlags.Public | BindingFlags.Static)!
            .Invoke(null, [type])!;

    private static Type RequireCanonicalIl() =>
        CanonicalIlType ?? throw new InvalidOperationException("The library has no canonical IL writer.");

    private static string CreateImplementation(Type type) =>
        (string)ContractHashType.GetMethod("CreateImplementation", BindingFlags.Public | BindingFlags.Static)!
            .Invoke(null, [type])!;

    private static string RawIl(Type type, string methodName) =>
        Convert.ToHexString(type.GetMethod(methodName)!.GetMethodBody()!.GetILAsByteArray()!);

    // Builds one dynamic assembly holding a probe type whose methods call a method of the same type, read a field,
    // use a string, a framework call and a catch clause. The unrelated types come first, so they
    // shift every metadata row and user-string offset that the probe's IL names, as an unrelated change would.
    private static Type EmitProbe(ProbeShape shape)
    {
        var assembly = AssemblyBuilder.DefineDynamicAssembly(
            new AssemblyName("MathBlocksFingerprintProbe") { Version = shape.Version },
            AssemblyBuilderAccess.RunAndCollect);
        var module = assembly.DefineDynamicModule("MathBlocksFingerprintProbe");
        for (var index = 0; index < shape.UnrelatedTypes; index++)
            EmitUnrelatedType(module, index);

        var type = module.DefineType(
            "Probe.Codec",
            TypeAttributes.Public | TypeAttributes.Abstract | TypeAttributes.Sealed);
        var counter = type.DefineField("Counter", typeof(int), FieldAttributes.Public | FieldAttributes.Static);
        var helper = type.DefineMethod(
            "Helper",
            MethodAttributes.Private | MethodAttributes.Static,
            typeof(int),
            [typeof(int)]);
        var il = helper.GetILGenerator();
        il.Emit(OpCodes.Ldarg_0);
        il.Emit(OpCodes.Ldc_I4, shape.Addend);
        il.Emit(OpCodes.Add);
        il.Emit(OpCodes.Ret);

        var run = type.DefineMethod(
            "Run",
            MethodAttributes.Public | MethodAttributes.Static,
            typeof(int),
            [typeof(int)]);
        il = run.GetILGenerator();
        var text = il.DeclareLocal(typeof(string));
        il.BeginExceptionBlock();
        il.Emit(OpCodes.Ldarg_0);
        il.Emit(OpCodes.Call, helper);
        il.Emit(OpCodes.Pop);
        il.BeginCatchBlock(typeof(InvalidOperationException));
        il.Emit(OpCodes.Pop);
        il.EndExceptionBlock();
        il.Emit(OpCodes.Ldstr, shape.Literal);
        il.Emit(
            OpCodes.Callvirt,
            typeof(string).GetMethod(shape.TrimEnd ? nameof(string.TrimEnd) : nameof(string.TrimStart), Type.EmptyTypes)!);
        il.Emit(OpCodes.Stloc, text);
        il.Emit(OpCodes.Ldloc, text);
        il.Emit(OpCodes.Callvirt, typeof(string).GetProperty(nameof(string.Length))!.GetMethod!);
        il.Emit(OpCodes.Ldarg_0);
        il.Emit(OpCodes.Call, helper);
        il.Emit(OpCodes.Add);
        il.Emit(OpCodes.Ldsfld, counter);
        il.Emit(OpCodes.Add);
        il.Emit(OpCodes.Ret);

        return type.CreateType();
    }

    private static void EmitUnrelatedType(ModuleBuilder module, int index)
    {
        var unrelated = module.DefineType(
            "Unrelated.Type" + index.ToString(CultureInfo.InvariantCulture),
            TypeAttributes.Public | TypeAttributes.Abstract | TypeAttributes.Sealed);
        unrelated.DefineField("Filler", typeof(long), FieldAttributes.Public | FieldAttributes.Static);
        var method = unrelated.DefineMethod(
            "Fill",
            MethodAttributes.Public | MethodAttributes.Static,
            typeof(string),
            Type.EmptyTypes);
        var il = method.GetILGenerator();
        il.Emit(OpCodes.Ldstr, "unrelated-" + index.ToString(CultureInfo.InvariantCulture));
        il.Emit(OpCodes.Ret);
        unrelated.CreateType();
    }

    private sealed record ProbeShape(Version Version, int UnrelatedTypes, string Literal, bool TrimEnd, int Addend = 1);

    // A method that calls through a function pointer, which compiles to an indirect call with a standalone signature.
    private static unsafe class FunctionPointerProbe
    {
        public static int Invoke(delegate*<int, int> target, int value) =>
            target(value);
    }

    // A type whose methods use every kind of token: a string, a field, a method of this type, constructed generic
    // members, a type token for a cast and an array, and a local.
    private static class TokenProbe
    {
        public static int Counter;

        public static string Describe(object value, int count)
        {
            Counter += count;
            var items = new List<int>();
            items.Add(count);
            var array = new long[count];
            var text = (string)value;
            return string.Concat(
                "probe-literal:",
                text,
                items.Count.ToString(CultureInfo.InvariantCulture),
                array.Length.ToString(CultureInfo.InvariantCulture),
                Helper(count));
        }

        private static string Helper(int value) =>
            value.ToString(CultureInfo.InvariantCulture);
    }
}
