namespace Supprocom.MathBlocks.Tests;

// The kernel maximum that the ArgumentOutOfRangeException of MathBlocksCudaOptionsValidator.ValidateKernel names: "... launches at most 640 threads per block ...".
internal static class MathBlockKernelMaximumMessage
{
    private const string Marker = "launches at most ";

    internal static int Parse(string message)
    {
        var start = message.IndexOf(Marker, StringComparison.Ordinal);
        Assert.True(start >= 0, $"The error does not name the kernel's maximum: {message}");
        var digits = new System.Text.StringBuilder();
        foreach (var character in message[(start + Marker.Length)..])
        {
            if (char.IsAsciiDigit(character))
                digits.Append(character);
            else if (character != ',')
                break;
        }

        return int.Parse(digits.ToString(), System.Globalization.CultureInfo.InvariantCulture);
    }
}
