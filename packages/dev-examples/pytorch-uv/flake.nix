{
  description = "PyTorch development: Python and uv, preconfigured for binary wheels on NixOS";

  inputs.nixpkgs.url = "@nixpkgsRef@";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          python = pkgs.python312;
        in
        {
          default = pkgs.mkShell {
            packages = [
              python
              pkgs.uv
            ];

            env = {
              # uv's standalone interpreter downloads assume a conventional
              # Linux; on NixOS they fail to link. With downloads off, uv
              # discovers the Nix python on PATH for `uv venv` and targets
              # the active venv afterwards. (Do not pin UV_PYTHON here: it
              # would override the activated venv and point installs at the
              # immutable store interpreter.)
              UV_PYTHON_DOWNLOADS = "never";
              # PyPI wheels with compiled extensions (torch above all) expect
              # to find libstdc++ and zlib next to the loader. Handing them
              # the Nix libraries here is what makes `uv pip install torch`
              # work unpatched on NixOS.
              LD_LIBRARY_PATH = nixpkgs.lib.makeLibraryPath [
                pkgs.stdenv.cc.cc.lib
                pkgs.zlib
              ];
            };

            shellHook = ''
              echo "pytorch dev shell: $(python --version), uv $(uv --version | cut -d' ' -f2)"
              echo "Quick start: uv venv && source .venv/bin/activate && uv pip install torch"
            '';
          };
        }
      );
    };
}
