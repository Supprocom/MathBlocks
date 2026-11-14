using System.Buffers.Binary;
using System.Collections.Immutable;
using System.Globalization;
using System.Reflection;
using System.Reflection.Emit;
using System.Reflection.Metadata;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.InteropServices;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>
/// Writes managed method bodies and type names as text that depends only on what defines their behaviour.
/// Every IL operand token (a metadata row number or a user-string heap offset, both assigned in emission order) is
/// replaced by the name it resolves to, and no name carries an assembly version, culture or public key token. An
/// unrelated change elsewhere in the assembly, a version bump or another compiler's token numbering therefore leaves
/// the text unchanged, while a change of a call target, a field, a type, a string, a constant or the control flow
/// changes it.
/// </summary>
internal static class MathBlockCudaCanonicalIl
{
    private static readonly OpCode[] SingleByteOpCodes = CreateOpCodeTable(twoByte: false);
    private static readonly OpCode[] TwoByteOpCodes = CreateOpCodeTable(twoByte: true);

    /// <summary>
    /// Writes the text that defines the behaviour of every method declared on a type: the method identity, the
    /// locals, the maximum stack depth, the exception clauses and the IL with every metadata token replaced by the
    /// version-free name it resolves to. It holds no assembly version, no metadata token and no heap offset, so only
    /// a change of what the methods do changes it.
    /// </summary>
    public static string CreateImplementationMaterial(Type type)
    {
        ArgumentNullException.ThrowIfNull(type);
        var reflectedMethods = type.GetMethods(
            BindingFlags.Public |
            BindingFlags.NonPublic |
            BindingFlags.Static |
            BindingFlags.DeclaredOnly);
        var methods = new List<MethodBase>(reflectedMethods.Length + 1);
        foreach (var method in reflectedMethods)
            methods.Add(method);
        if (type.TypeInitializer is not null)
            methods.Add(type.TypeInitializer);
        methods.Sort((left, right) => StringComparer.Ordinal.Compare(
            CreateMethodIdentity(left),
            CreateMethodIdentity(right)));

        var material = new StringBuilder("mathblocks-managed-implementation-v2\n")
            .Append(CreateTypeName(type)).Append('\n');
        foreach (ref readonly var method in CollectionsMarshal.AsSpan(methods))
        {
            material.Append(CreateMethodIdentity(method)).Append('\n');
            var body = method.GetMethodBody();
            if (body is null)
            {
                material.Append("body:none\n");
                continue;
            }

            material.Append(body.InitLocals ? "init-locals:1\n" : "init-locals:0\n")
                .Append("max-stack:")
                .Append(body.MaxStackSize.ToString(CultureInfo.InvariantCulture))
                .Append('\n');
            foreach (var local in body.LocalVariables)
            {
                material.Append("local:")
                    .Append(local.LocalIndex.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(CreateTypeName(local.LocalType)).Append(':')
                    .Append(local.IsPinned ? '1' : '0').Append('\n');
            }
            foreach (var clause in body.ExceptionHandlingClauses)
            {
                material.Append("clause:")
                    .Append(((int)clause.Flags).ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.TryOffset.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.TryLength.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.HandlerOffset.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.HandlerLength.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append((clause.Flags == ExceptionHandlingClauseOptions.Filter
                        ? clause.FilterOffset
                        : -1).ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.Flags == ExceptionHandlingClauseOptions.Clause && clause.CatchType is not null
                        ? CreateTypeName(clause.CatchType)
                        : null).Append('\n');
            }
            material.Append("il:\n");
            AppendInstructions(material, method, body.GetILAsByteArray() ?? []);
        }
        return material.ToString();
    }

    /// <summary>Gets a type name made of the full name alone, with every generic argument written the same way.</summary>
    public static string CreateTypeName(Type type)
    {
        ArgumentNullException.ThrowIfNull(type);
        var builder = new StringBuilder();
        AppendTypeName(builder, type);
        return builder.ToString();
    }

    /// <summary>Gets the method name, generic arguments, parameter types and return type of a method.</summary>
    public static string CreateMethodIdentity(MethodBase method)
    {
        ArgumentNullException.ThrowIfNull(method);
        var builder = new StringBuilder();
        AppendMethodIdentity(builder, method);
        return builder.ToString();
    }

    /// <summary>Appends one line per IL instruction, with token operands replaced by canonical names.</summary>
    public static void AppendInstructions(StringBuilder builder, MethodBase method, byte[] il)
    {
        ArgumentNullException.ThrowIfNull(builder);
        ArgumentNullException.ThrowIfNull(method);
        ArgumentNullException.ThrowIfNull(il);
        var module = method.Module;
        var declaringType = method.DeclaringType;
        var typeArguments = declaringType is { IsGenericType: true } ? declaringType.GetGenericArguments() : null;
        var methodArguments = method is MethodInfo { IsGenericMethodDefinition: true }
            ? method.GetGenericArguments()
            : null;
        var offset = 0;
        while (offset < il.Length)
        {
            OpCode opCode;
            if (il[offset] == 0xFE)
            {
                if (offset + 1 >= il.Length)
                    throw new InvalidOperationException("The IL ends inside a two-byte opcode.");
                opCode = TwoByteOpCodes[il[offset + 1]];
                offset += 2;
            }
            else
            {
                opCode = SingleByteOpCodes[il[offset]];
                offset++;
            }

            if (opCode.Name is null)
                throw new InvalidOperationException("The IL holds an opcode that is not defined.");
            builder.Append(opCode.Name);
            offset = AppendOperand(builder, opCode, il, offset, module, typeArguments, methodArguments);
            builder.Append('\n');
        }
    }

    private static OpCode[] CreateOpCodeTable(bool twoByte)
    {
        var table = new OpCode[256];
        foreach (var field in typeof(OpCodes).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            var opCode = (OpCode)field.GetValue(null)!;
            if ((opCode.Size == 2) == twoByte)
                table[opCode.Value & 0xFF] = opCode;
        }

        return table;
    }

    private static int AppendOperand(
        StringBuilder builder,
        OpCode opCode,
        byte[] il,
        int offset,
        Module module,
        Type[]? typeArguments,
        Type[]? methodArguments)
    {
        var span = il.AsSpan(offset);
        switch (opCode.OperandType)
        {
            case OperandType.InlineNone:
                return offset;
            case OperandType.ShortInlineBrTarget:
            case OperandType.ShortInlineI:
            case OperandType.ShortInlineVar:
                builder.Append(' ').Append(span[0].ToString(CultureInfo.InvariantCulture));
                return offset + sizeof(byte);
            case OperandType.InlineVar:
                builder.Append(' ')
                    .Append(BinaryPrimitives.ReadInt16LittleEndian(span).ToString(CultureInfo.InvariantCulture));
                return offset + sizeof(short);
            case OperandType.InlineI:
            case OperandType.InlineBrTarget:
                builder.Append(' ')
                    .Append(BinaryPrimitives.ReadInt32LittleEndian(span).ToString(CultureInfo.InvariantCulture));
                return offset + sizeof(int);
            case OperandType.ShortInlineR:
                builder.Append(' ').Append(Convert.ToHexString(span[..sizeof(int)]));
                return offset + sizeof(int);
            case OperandType.InlineI8:
            case OperandType.InlineR:
                builder.Append(' ').Append(Convert.ToHexString(span[..sizeof(long)]));
                return offset + sizeof(long);
            case OperandType.InlineSwitch:
                return AppendSwitchTargets(builder, il, offset);
            case OperandType.InlineString:
            case OperandType.InlineSig:
            case OperandType.InlineField:
            case OperandType.InlineMethod:
            case OperandType.InlineTok:
            case OperandType.InlineType:
                builder.Append(' ');
                AppendToken(
                    builder,
                    opCode.OperandType,
                    module,
                    BinaryPrimitives.ReadInt32LittleEndian(span),
                    typeArguments,
                    methodArguments);
                return offset + sizeof(int);
            default:
                throw new InvalidOperationException(
                    $"The IL opcode '{opCode.Name}' has an operand kind that is not supported.");
        }
    }

    private static int AppendSwitchTargets(StringBuilder builder, byte[] il, int offset)
    {
        var count = BinaryPrimitives.ReadInt32LittleEndian(il.AsSpan(offset));
        offset += sizeof(int);
        builder.Append(" switch");
        for (var index = 0; index < count; index++)
        {
            builder.Append(' ')
                .Append(BinaryPrimitives.ReadInt32LittleEndian(il.AsSpan(offset)).ToString(CultureInfo.InvariantCulture));
            offset += sizeof(int);
        }

        return offset;
    }

    private static void AppendToken(
        StringBuilder builder,
        OperandType operandType,
        Module module,
        int token,
        Type[]? typeArguments,
        Type[]? methodArguments)
    {
        switch (operandType)
        {
            case OperandType.InlineString:
                AppendLiteral(builder, module.ResolveString(token));
                return;
            case OperandType.InlineSig:
                builder.Append("SIG:").Append(CreateSignatureText(module, module.ResolveSignature(token)));
                return;
            case OperandType.InlineType:
                builder.Append("T:");
                AppendTypeName(builder, module.ResolveType(token, typeArguments, methodArguments));
                return;
        }

        switch (module.ResolveMember(token, typeArguments, methodArguments))
        {
            case MethodBase method:
                builder.Append("M:");
                AppendDeclaringType(builder, method.DeclaringType);
                builder.Append("::");
                AppendMethodIdentity(builder, method);
                break;
            case FieldInfo field:
                builder.Append("F:");
                AppendDeclaringType(builder, field.DeclaringType);
                builder.Append("::").Append(field.Name).Append(':');
                AppendTypeName(builder, field.FieldType);
                break;
            case Type type:
                builder.Append("T:");
                AppendTypeName(builder, type);
                break;
            default:
                throw new InvalidOperationException(
                    $"The IL token 0x{token:X8} resolves to a member kind that is not supported.");
        }
    }

    private static void AppendLiteral(StringBuilder builder, string literal) =>
        builder.Append("S:").Append(literal.Length.ToString(CultureInfo.InvariantCulture)).Append(':').Append(literal);

    private static void AppendDeclaringType(StringBuilder builder, Type? declaringType)
    {
        if (declaringType is null)
            builder.Append("<module>");
        else
            AppendTypeName(builder, declaringType);
    }

    private static void AppendMethodIdentity(StringBuilder builder, MethodBase method)
    {
        builder.Append(method.Name);
        if (method.IsGenericMethod)
        {
            builder.Append('<');
            AppendTypeList(builder, method.GetGenericArguments());
            builder.Append('>');
        }

        builder.Append('(');
        var parameters = method.GetParameters();
        for (var index = 0; index < parameters.Length; index++)
        {
            if (index != 0)
                builder.Append(',');
            AppendTypeName(builder, parameters[index].ParameterType);
        }

        builder.Append(')');
        if (method is MethodInfo methodInfo)
        {
            builder.Append("->");
            AppendTypeName(builder, methodInfo.ReturnType);
        }
    }

    private static void AppendTypeList(StringBuilder builder, Type[] types)
    {
        for (var index = 0; index < types.Length; index++)
        {
            if (index != 0)
                builder.Append(',');
            AppendTypeName(builder, types[index]);
        }
    }

    private static void AppendTypeName(StringBuilder builder, Type type)
    {
        if (type.IsGenericParameter)
        {
            builder.Append(type.DeclaringMethod is null ? "!" : "!!")
                .Append(type.GenericParameterPosition.ToString(CultureInfo.InvariantCulture));
        }
        else if (type.IsFunctionPointer)
        {
            builder.Append("fnptr(");
            AppendTypeList(builder, type.GetFunctionPointerParameterTypes());
            builder.Append(")->");
            AppendTypeName(builder, type.GetFunctionPointerReturnType());
        }
        else if (type.HasElementType)
        {
            AppendTypeName(builder, type.GetElementType()!);
            if (type.IsSZArray)
                builder.Append("[]");
            else if (type.IsArray)
                builder.Append(CreateArraySuffix(type.GetArrayRank()));
            else
                builder.Append(type.IsByRef ? '&' : '*');
        }
        else if (type.IsGenericType && !type.IsGenericTypeDefinition)
        {
            AppendTypeName(builder, type.GetGenericTypeDefinition());
            builder.Append('<');
            AppendTypeList(builder, type.GetGenericArguments());
            builder.Append('>');
        }
        else
        {
            builder.Append(type.FullName ?? type.Name);
        }
    }

    private static string CreateArraySuffix(int rank) =>
        rank == 1 ? "[*]" : "[" + new string(',', rank - 1) + "]";

    private static unsafe string CreateSignatureText(Module module, byte[] signature)
    {
        if (!module.Assembly.TryGetRawMetadata(out var metadata, out var length))
            throw new InvalidOperationException("The assembly metadata is not available to read a signature.");
        var reader = new MetadataReader(metadata, length);
        fixed (byte* pinned = signature)
        {
            var blob = new BlobReader(pinned, signature.Length);
            var decoded = new SignatureDecoder<string, int>(new SignatureTextProvider(module), reader, 0)
                .DecodeMethodSignature(ref blob);
            return FormatMethodSignature(decoded);
        }
    }

    private static string FormatMethodSignature(MethodSignature<string> signature) =>
        string.Create(
            CultureInfo.InvariantCulture,
            $"{signature.Header.CallingConvention}{(signature.Header.IsInstance ? " instance" : string.Empty)} generic={signature.GenericParameterCount} required={signature.RequiredParameterCount} ({string.Join(',', signature.ParameterTypes)})->{signature.ReturnType}");

    private sealed class SignatureTextProvider(Module module) : ISignatureTypeProvider<string, int>
    {
        public string GetPrimitiveType(PrimitiveTypeCode typeCode) =>
            typeCode.ToString();

        public string GetTypeFromDefinition(MetadataReader reader, TypeDefinitionHandle handle, byte rawTypeKind) =>
            CreateTypeName(module.ResolveType(MetadataTokens.GetToken((EntityHandle)handle)));

        public string GetTypeFromReference(MetadataReader reader, TypeReferenceHandle handle, byte rawTypeKind) =>
            CreateTypeName(module.ResolveType(MetadataTokens.GetToken((EntityHandle)handle)));

        public string GetTypeFromSpecification(
            MetadataReader reader,
            int genericContext,
            TypeSpecificationHandle handle,
            byte rawTypeKind) =>
            reader.GetTypeSpecification(handle).DecodeSignature(this, genericContext);

        public string GetArrayType(string elementType, ArrayShape shape) =>
            elementType + CreateArraySuffix(shape.Rank);

        public string GetByReferenceType(string elementType) =>
            elementType + "&";

        public string GetFunctionPointerType(MethodSignature<string> signature) =>
            "fnptr " + FormatMethodSignature(signature);

        public string GetGenericInstantiation(string genericType, ImmutableArray<string> typeArguments) =>
            genericType + "<" + string.Join(',', typeArguments) + ">";

        public string GetGenericMethodParameter(int genericContext, int index) =>
            "!!" + index.ToString(CultureInfo.InvariantCulture);

        public string GetGenericTypeParameter(int genericContext, int index) =>
            "!" + index.ToString(CultureInfo.InvariantCulture);

        public string GetModifiedType(string modifier, string unmodifiedType, bool isRequired) =>
            unmodifiedType + (isRequired ? " modreq(" : " modopt(") + modifier + ")";

        public string GetPinnedType(string elementType) =>
            elementType + " pinned";

        public string GetPointerType(string elementType) =>
            elementType + "*";

        public string GetSZArrayType(string elementType) =>
            elementType + "[]";
    }
}
