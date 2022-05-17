# Xcode-Swift2Assembly

Generates assembly from the Swift sources in an Xcode project.

## Why?

When developing in Objective-C, Xcode offers a menu comand for generating assembly from the ObjC source in the code editor.  For Swift sources that menu command doesn't exist.  As long as the header files can be found, (Obj)C(++) sources can be compiled to assembly in isolation.  Swift has no header files, so to generate assembly from Swift, you also have to pass the soures of all dependencies to the compiler.  This is tedious to do manually, and you'd have to leave Xcode for the command line to do it.  This repo automates that task inside Xcode.

## How?

### Once, and First

Running `make` in this repo's directory will install `swift2asm` in `${HOME}/bin`.

### For Each Xcode Project

You create a **Run Script** build phase in the **Build Phases** tab of your app/library target and paste the glue code from `XcodeBuildPhase-GenerateAssembly.sh` into its code box.  You can leave all other options in that build phase unchanged.

The glue code passes the path of your target's source root folder to the `swift2asm` tool.  `swift2asm` collects all Swift sources in that directory tree and passes them to the Swift compiler, along with other project-specific options.  The output will be a single `<TargetName>.s` file in the target's source root folder with the assembly code from the Swift soures.

Each time you run Xcode's Build command for that target, generating the assembly file will be one of the build steps.

For ARM targets, you'll see ARM64 code.  For x86 targets (Intel Mac, simulators), you'll see x86_64 code.
