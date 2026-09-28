using System.Globalization;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlockCudaContractHash
{
    public static string Create(string value) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value)));

    public static unsafe string CreateValue(MathBlockValue value)
    {
        var capacity = value.IsValid ? MathBlockCudaValueCodec.GetElementCount(value) : 0;
        var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
        var byteCount = checked(MathBlockCudaSlotLayout.Size + payloadBytes);
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            new Span<byte>((void*)arena, byteCount).Clear();
            MathBlockCudaValueCodec.WriteValue(
                arena,
                0,
                payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                0ul,
                0ul,
                capacity,
                value);
            var bytes = new byte[byteCount];
            Marshal.Copy(arena, bytes, 0, byteCount);
            return Convert.ToHexString(SHA256.HashData(bytes));
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }

    public static string CreateImplementation(Type type)
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

        var material = new StringBuilder("mathblocks-managed-implementation-v1\n")
            .Append(type.FullName).Append('\n');
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
                    .Append(local.LocalType.AssemblyQualifiedName).Append(':')
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
                    .Append(clause.Flags == ExceptionHandlingClauseOptions.Clause
                        ? clause.CatchType?.AssemblyQualifiedName
                        : null).Append('\n');
            }
            material.Append("il:")
                .Append(Convert.ToHexString(body.GetILAsByteArray() ?? []))
                .Append('\n');
        }
        return Create(material.ToString());
    }

    private static string CreateMethodIdentity(MethodBase method)
    {
        var identity = new StringBuilder(method.Name).Append('(');
        var parameters = method.GetParameters();
        for (var index = 0; index < parameters.Length; index++)
        {
            if (index != 0)
                identity.Append(',');
            identity.Append(parameters[index].ParameterType.AssemblyQualifiedName);
        }
        identity.Append(')');
        if (method is MethodInfo methodInfo)
            identity.Append("->").Append(methodInfo.ReturnType.AssemblyQualifiedName);
        return identity.ToString();
    }
}
