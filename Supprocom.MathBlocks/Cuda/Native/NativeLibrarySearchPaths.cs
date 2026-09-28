using System.Runtime.InteropServices;

// Keep CUDA and NVRTC probing in trusted application, user-added, and system
// locations; never search the process current working directory.
[assembly: DefaultDllImportSearchPaths(DllImportSearchPath.SafeDirectories)]
