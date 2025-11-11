## Monorepo Boilerplate

A minimal, batteries-included TypeScript monorepo using npm workspaces, Vitest, and `tsup`. It’s designed to help you quickly add packages/apps and share configuration.

### Features

- **Workspaces**: Managed via npm workspaces (`packages/*`, `apps/*`)
- **TypeScript**: Shared `tsconfig.base.json`
- **Build**: `tsup` for ESM + CJS outputs with type declarations
- **Testing**: Vitest with coverage and watch mode
- **Node**: ESM-first setup, supports dual exports per package

### Getting Started

1. Install dependencies (workspace-aware):
   ```bash
   npm install
   ```
2. Build all packages/apps (skips those without a build script):
   ```bash
   npm run build
   ```
3. Run tests across the monorepo (unit tests + root vitest run):
   ```bash
   npm run test
   ```
4. Watch tests:
   ```bash
   npm run test:watch
   ```
5. Generate coverage:
   ```bash
   npm run coverage
   ```

### Repository Structure

```
.
├─ package.json            # workspaces + root scripts
├─ tsconfig.base.json      # shared TS config
├─ vitest.config.ts        # root test configuration
└─ packages/
   └─ demo-package/
      ├─ package.json
      ├─ src/
      │  └─ index.ts
      └─ tsconfig.json
```

### Workspace Scripts (root)

- `npm run build`: Runs `build` in all workspaces if present
- `npm run test`: Runs `test` in all workspaces if present, then `vitest run`
- `npm run test:watch`: Runs `vitest` in watch mode at the root
- `npm run coverage`: Runs `vitest` with coverage at the root

### Package Conventions

Each package should:

- Be placed in `packages/<name>`
- Export both ESM and CJS if needed (via `exports` field)
- Emit types to `dist` and set `types`, `main` (CJS), `module`/ESM path appropriately
- Have `build` and optional `dev` scripts

Example (`packages/demo-package/package.json`):

```json
{
  "name": "@demo-package",
  "version": "0.0.1",
  "types": "./dist/index.d.ts",
  "main": "./dist/index.js",
  "type": "module",
  "require": "./dist/index.cjs",
  "exports": {
    ".": {
      "require": "./dist/index.cjs",
      "import": "./dist/index.js"
    }
  },
  "files": ["dist"],
  "scripts": {
    "build": "tsup-node src/index.ts --format esm,cjs --dts",
    "dev": "tsx src/index.ts",
    "test": "vitest run"
  }
}
```

### Creating a New Package

1. Scaffold a folder:
   ```bash
   mkdir -p packages/my-new-package/src
   ```
2. Add a minimal `package.json` (adapt from the example above). Ensure it has a `build` script.
3. Add `src/index.ts` with your exports.
4. Optionally add a `tsconfig.json` if you need overrides; otherwise inherit from `tsconfig.base.json`.
5. Build:
   ```bash
   npm run build
   ```
6. (Optional) Add tests under `packages/my-new-package/**/*.test.ts` and run:
   ```bash
   npm run test
   ```

### TypeScript

- Shared options live in `tsconfig.base.json` (ESNext target/module, strict, declaration output to `dist`, sourcemaps).
- Packages can extend or override via local `tsconfig.json`.

### Testing

- Root `vitest.config.ts` includes all `**/*.test.ts` by default and ignores `dist` and `node_modules`.
- Run from the root for consistent environment and coverage.

### Publishing

- The root is marked `"private": true`; publish individual packages from within their directory.
- Typical flow:
  ```bash
  cd packages/<your-package>
  npm version <patch|minor|major>
  npm publish --access public
  ```
- Ensure your package `package.json` has the correct `name`, `version`, `files`, and `exports` fields.

### FAQ

- Q: Can I use pnpm or yarn?
  - A: Root config targets npm workspaces. You can migrate, but adjust scripts and lockfiles accordingly.
- Q: How do I add an app?
  - A: Create `apps/<name>` with its own `package.json`. It will be picked up by workspaces.

### License

ISC (update as needed).
