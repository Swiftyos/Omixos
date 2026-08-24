# PyTorch + uv development environment

Python 3.12 and [uv](https://docs.astral.sh/uv/), with the environment
variables that make binary wheels (PyTorch above all) run unpatched on
NixOS: uv is told to use the Nix python instead of downloading its own, and
`LD_LIBRARY_PATH` hands the wheels the libstdc++/zlib they expect.

## Start a project

```console
nix develop
uv init my-project && cd my-project
uv add torch
uv run python -c 'import torch; print(torch.__version__)'
```

Or the classic virtualenv flow in an existing directory:

```console
uv venv
source .venv/bin/activate
uv pip install torch numpy
```

On ARM64 the stock `torch` wheel runs CPU-only out of the box — correct for
a Pi or an ARM VM (verified: `torch.rand(3,3) @ torch.rand(3,3)` on this
environment). For CUDA or ROCm machines, follow
<https://pytorch.org/get-started/locally/> to pick the matching index URL.

## Notes

- Everything uv installs stays inside the project's `.venv`; delete the
  directory and it is gone.
- If `import torch` ever fails with a `libstdc++.so.6` error, you are
  outside the dev shell — the `LD_LIBRARY_PATH` this flake sets is what
  satisfies that lookup on NixOS.
- Prefer a fully Nix-managed alternative? `python3.withPackages (p: [ p.torch ])`
  in any flake builds PyTorch from the nixpkgs set instead of PyPI wheels —
  heavier first build, but no wheel caveats.
