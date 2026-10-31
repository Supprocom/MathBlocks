using System.Globalization;
using System.Text;
using MathBlocks.FormulaProfileGenerator;
using Supprocom.MathBlocks;

if (args.Length == 0 || args.Length % 2 != 0)
{
    Console.Error.WriteLine("Use paired formula profile generator options.");
    return 2;
}

string? outputOption = null;
string? openMathSampleOption = null;
string? mathMlSampleOption = null;
var profileVersion = 1;
for (var index = 0; index < args.Length; index += 2)
{
    switch (args[index])
    {
        case "--output":
            outputOption = args[index + 1];
            break;
        case "--openmath-sample":
            openMathSampleOption = args[index + 1];
            break;
        case "--mathml-sample":
            mathMlSampleOption = args[index + 1];
            break;
        case "--profile":
            if (args[index + 1] is not ("1" or "2"))
            {
                Console.Error.WriteLine($"The formula profile version '{args[index + 1]}' is not supported.");
                return 2;
            }
            profileVersion = int.Parse(args[index + 1], CultureInfo.InvariantCulture);
            break;
        default:
            Console.Error.WriteLine($"The formula profile generator option '{args[index]}' is not supported.");
            return 2;
    }
}

if (outputOption is null)
{
    Console.Error.WriteLine("The --output option is required.");
    return 2;
}

var outputDirectory = Path.GetFullPath(outputOption);
Directory.CreateDirectory(outputDirectory);

foreach (var artifact in FormulaProfileArtifacts.Create(
             profileVersion,
             FormulaProfileArtifacts.Mappings(profileVersion)))
{
    File.WriteAllBytes(Path.Combine(outputDirectory, artifact.Name), artifact.Content);
}

// The samples use the published descriptor, so a Profile 2 sample requires that the embedded
// Profile 2 artifacts and their hash locks are current.
var sample = CreateSampleProgram();
if (openMathSampleOption is not null)
{
    WriteSample(
        openMathSampleOption,
        MathBlockFormulaInterchange.Export(
            sample,
            "result",
            MathBlockFormulaFormat.OpenMath,
            PublishedProfile(profileVersion)));
}
if (mathMlSampleOption is not null)
{
    WriteSample(
        mathMlSampleOption,
        MathBlockFormulaInterchange.Export(
            sample,
            "result",
            MathBlockFormulaFormat.ContentMathMl,
            PublishedProfile(profileVersion)));
}

Console.WriteLine(
    $"Generated Formula Interchange Profile {profileVersion.ToString(CultureInfo.InvariantCulture)} in '{outputDirectory}'.");
return 0;

static MathBlockFormulaProfileDescriptor PublishedProfile(int version) =>
    version == 1 ? MathBlockFormulaInterchange.Profile : MathBlockFormulaInterchange.Profile2;

static MathBlockProgram CreateSampleProgram()
{
    var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
    var left = builder.Input("left", MathBlockType.Scalar());
    var right = builder.Input("right", MathBlockType.Scalar());
    var sum = builder.Apply("scalar.add", inputs: [left, right]);
    var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
    var result = builder.Apply("scalar.softplus", inputs: [square]);
    return builder.Output("result", result).Build();
}

static void WriteSample(string sourcePath, string source)
{
    var path = Path.GetFullPath(sourcePath);
    var directory = Path.GetDirectoryName(path) ??
        throw new InvalidOperationException("The sample path has no directory.");
    Directory.CreateDirectory(directory);
    File.WriteAllText(path, source, new UTF8Encoding(false));
}
