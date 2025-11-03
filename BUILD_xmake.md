# Build with XMake

## C++ with XMake

- [XMake](https://xmake.io/) 3.0.4+
- Building with XMake on Linux and macOS is experimental. You may encounter with RPATH issues. Please use CMake instead.

## XMake Build Commands

```bash
xmake f -m release -c
xmake
```
adding options at command line, for instance, use LLVM toolchain:
```bash
xmake f -m release --toolchain=llvm -c
```

## Development workflow
* Generate compile_commands.json: `xmake project -k compile_commands --lsp=clangd /.vscode`
* Use LLVM-based inttellisense(clangd, ccls, etc.): .vscode/settings.json
