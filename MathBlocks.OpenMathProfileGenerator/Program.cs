using System.Globalization;
using System.Text;
using MathBlocks.OpenMathProfileGenerator;
using Supprocom.MathBlocks;

if (args.Length == 0 || args.Length % 2 != 0)
{
    Console.Error.WriteLine("Use paired profile generator options.");
    return 2;
}

string? outputOption = null;
string? sampleOption = null;
string? catalogSampleOption = null;
var profileVersion = 1;
for (var index = 0; index < args.Length; index += 2)
{
    switch (args[index])
    {
        case "--output":
            outputOption = args[index + 1];
            break;
        case "--sample":
            sampleOption = args[index + 1];
            break;
        case "--catalog-sample":
            catalogSampleOption = args[index + 1];
            break;
        case "--profile":
            if (args[index + 1] is not ("1" or "2"))
            {
                Console.Error.WriteLine($"The profile version '{args[index + 1]}' is not supported.");
                return 2;
            }
            profileVersion = int.Parse(args[index + 1], CultureInfo.InvariantCulture);
            break;
        default:
            Console.Error.WriteLine($"The profile generator option '{args[index]}' is not supported.");
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

foreach (var artifact in OpenMathProfileArtifacts.Create(
             profileVersion,
             OpenMathProfileArtifacts.Operations(profileVersion)))
{
    File.WriteAllBytes(Path.Combine(outputDirectory, artifact.Name), artifact.Content);
}

// The samples use the published descriptor, so a Profile 2 sample requires that the embedded
// Profile 2 artifacts and their hash locks are current.
if (sampleOption is not null)
    WriteSample(sampleOption, CreateSampleProgram(), PublishedProfile(profileVersion));
if (catalogSampleOption is not null)
{
    var profile = PublishedProfile(profileVersion);
    WriteSample(catalogSampleOption, CreateCatalogSampleProgram(profile), profile);
}

Console.WriteLine(
    $"Generated MathBlocks OpenMath Profile {profileVersion.ToString(CultureInfo.InvariantCulture)} in '{outputDirectory}'.");
return 0;

static MathBlockOpenMathProfileDescriptor PublishedProfile(int version) =>
    version == 1 ? MathBlockOpenMath.Profile : MathBlockOpenMath.Profile2;

static MathBlockProgram CreateSampleProgram()
{
    var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
    var left = builder.Input("left", MathBlockType.Scalar());
    var right = builder.Input("right", MathBlockType.Scalar());
    var sum = builder.Apply("scalar.add", inputs: [left, right]);
    var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
    return builder.Output("sum", sum).Output("square", square).Build();
}

static MathBlockProgram CreateCatalogSampleProgram(MathBlockOpenMathProfileDescriptor profile)
{
    var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
    var operations = profile.Operations;
    for (var operationIndex = 0; operationIndex < operations.Count; operationIndex++)
    {
        var operation = operations[operationIndex].Operation;
        var regressionCase = operation.RegressionCases[0];
        var inputs = new int[regressionCase.Inputs.Count];
        for (var inputIndex = 0; inputIndex < inputs.Length; inputIndex++)
            inputs[inputIndex] = builder.Constant(regressionCase.Inputs[inputIndex]);
        var result = builder.Apply(operation.Identifier, operation.Version, inputs);
        builder.Output(
            string.Concat("operation-", operationIndex.ToString("D3", CultureInfo.InvariantCulture)),
            result);
    }
    return builder.Build();
}

static void WriteSample(
    string sourcePath,
    MathBlockProgram program,
    MathBlockOpenMathProfileDescriptor profile)
{
    var path = Path.GetFullPath(sourcePath);
    var directory = Path.GetDirectoryName(path) ??
        throw new InvalidOperationException("The sample path has no directory.");
    Directory.CreateDirectory(directory);
    File.WriteAllText(path, MathBlockOpenMath.Export(program, profile), new UTF8Encoding(false));
}
