{
  description = "n8n workflow automation: Node.js runtime and native-module toolchain";

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
              pkgs.nodejs_22
              pkgs.pnpm
              # n8n dependencies with native addons (sqlite3 and friends)
              # compile through node-gyp, which needs these at install time.
              pkgs.python3
              pkgs.gnumake
              pkgs.gcc
              pkgs.pkg-config
            ];

            shellHook = ''
              echo "n8n dev shell: node $(node --version), pnpm $(pnpm --version)"
              echo "Quick start: npx n8n   (data lands in ~/.n8n)"
            '';
          };
        }
      );
    };
}
