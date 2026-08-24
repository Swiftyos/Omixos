# llama.cpp development environment

CMake, ninja, gcc, OpenBLAS, and the Python model-conversion tooling for
building llama.cpp from source.

## Build

```console
nix develop
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build -G Ninja -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
cmake --build build --config Release
```

On ARM64 (including this machine) the build picks up NEON automatically; no
flags needed. Drop the two BLAS options for a plain build.

## Run a model

```console
./build/bin/llama-cli -hf ggml-org/gemma-3-1b-it-GGUF
```

`-hf` downloads a GGUF from Hugging Face into `~/.cache/llama.cpp` on first
use. `llama-server -hf <repo>` starts the OpenAI-compatible HTTP server on
<http://localhost:8080> instead. Small quantized models (1–4B, Q4) are the
realistic ceiling for CPU inference on a Pi-class board.

## Convert your own models

The dev shell's python includes numpy, sentencepiece, and safetensors:

```console
python convert_hf_to_gguf.py ~/models/my-model --outfile my-model.gguf
./build/bin/llama-quantize my-model.gguf my-model-q4_k_m.gguf q4_k_m
```

## Just want the binaries?

A prebuilt llama.cpp ships in nixpkgs — `nix run nixpkgs#llama-cpp` — but it
trails upstream, which moves fast. This environment exists for building at
whatever commit you need.
