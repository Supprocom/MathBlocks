#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef void *nvrtcProgram;
typedef int nvrtcResult;

extern nvrtcResult nvrtcCreateProgram(nvrtcProgram *, const char *, const char *, int,
                                     const char *const *, const char *const *);
extern nvrtcResult nvrtcCompileProgram(nvrtcProgram, int, const char *const *);
extern nvrtcResult nvrtcGetProgramLogSize(nvrtcProgram, size_t *);
extern nvrtcResult nvrtcGetProgramLog(nvrtcProgram, char *);
extern nvrtcResult nvrtcGetPTXSize(nvrtcProgram, size_t *);
extern nvrtcResult nvrtcDestroyProgram(nvrtcProgram *);

int main(int argc, char **argv)
{
    if (argc != 2)
        return 2;

    FILE *input = fopen(argv[1], "rb");
    if (input == NULL)
        return 3;
    if (fseek(input, 0, SEEK_END) != 0)
        return 4;
    long length = ftell(input);
    if (length < 0 || fseek(input, 0, SEEK_SET) != 0)
        return 5;

    static const char kernel[] =
        "\nextern \"C\" __global__ void mathblocks_nvrtc_smoke(MathBlockSlot* slots) {\n"
        "  if (blockIdx.x != 0) return;\n"
        "  const MathBlockSlot* inputs[2] = { &slots[0], &slots[1] };\n"
        "  mathblocks_operation_dispatch(6, 0, inputs, 2, &slots[2]);\n"
        "}\n";
    char *source = malloc((size_t)length + sizeof(kernel));
    if (source == NULL)
        return 6;
    if (fread(source, 1, (size_t)length, input) != (size_t)length)
        return 7;
    fclose(input);
    memcpy(source + length, kernel, sizeof(kernel));

    nvrtcProgram program = NULL;
    nvrtcResult result = nvrtcCreateProgram(&program, source, "mathblocks-smoke.cu", 0, NULL, NULL);
    if (result != 0) {
        fprintf(stderr, "nvrtcCreateProgram failed: %d\n", result);
        return 8;
    }

    const char *options[] = {
        "--gpu-architecture=compute_80", "--fmad=false", "--prec-div=true", "--prec-sqrt=true"
    };
    result = nvrtcCompileProgram(program, 4, options);
    if (result != 0) {
        size_t log_length = 0;
        if (nvrtcGetProgramLogSize(program, &log_length) == 0 && log_length > 1) {
            char *log = malloc(log_length);
            if (log != NULL && nvrtcGetProgramLog(program, log) == 0)
                fprintf(stderr, "%s\n", log);
            free(log);
        }
        fprintf(stderr, "nvrtcCompileProgram failed: %d\n", result);
        return 9;
    }

    size_t ptx_length = 0;
    result = nvrtcGetPTXSize(program, &ptx_length);
    if (result != 0 || ptx_length < 1000)
        return 10;

    printf("NVRTC compiled CUDA source; PTX bytes=%zu\n", ptx_length);
    nvrtcDestroyProgram(&program);
    free(source);
    return 0;
}
