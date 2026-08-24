# n8n development environment

Node.js 22, pnpm, and the node-gyp toolchain n8n's native modules need.

## Run n8n

```console
nix develop
npx n8n
```

The first run downloads n8n into npx's cache; the editor then listens on
<http://localhost:5678>. Workflows, credentials, and the SQLite database live
in `~/.n8n`, so they survive leaving the shell.

To pin a version instead of tracking the latest release:

```console
npx n8n@1.100.1
```

## Develop custom nodes

```console
nix develop
pnpm create @n8n/node my-node
cd my-node && pnpm install && pnpm build
```

Then point n8n at it with `N8N_CUSTOM_EXTENSIONS=$PWD/dist npx n8n`, or link
the package into `~/.n8n/custom/`. The full guide lives at
<https://docs.n8n.io/integrations/creating-nodes/>.

## Notes

- n8n itself is intentionally not baked into the environment: workflow
  projects usually track n8n releases faster than system packages, and npx
  keeps the choice per-project.
- If a `pnpm install` fails while compiling a native module, you are most
  likely outside the dev shell; `node-gyp` needs the python/gcc/make this
  flake provides.
