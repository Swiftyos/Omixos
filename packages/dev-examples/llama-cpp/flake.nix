{
  description = "llama.cpp development: C/C++ toolchain for building from source";

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
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.cmake
              pkgs.ninja
              pkgs.pkg-config
              pkgs.gcc
              pkgs.git
              # llama-server's download helper and the HTTP examples link curl.
              pkgs.curl
              # Faster prompt processing on CPU builds.
              pkgs.openblas
              # convert_hf_to_gguf.py and the other model tooling.
              (pkgs.python3.withPackages (python-pkgs: [
                python-pkgs.numpy
                python-pkgs.sentencepiece
                python-pkgs.safetensors
              ]))
            ];

            shellHook = ''
              echo "llama.cpp dev shell: $(cmake --version | head -n1), gcc $(gcc -dumpversion)"
              echo "Quick start: see README.md next to this flake"
            '';
          };
        }
      );
    };
}
