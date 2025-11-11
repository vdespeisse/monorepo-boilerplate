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
   └─ (your-packages-here)
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

Templates for `package.json`, `tsconfig.json`, and `src/index.ts` live under `scripts/boilerplate/`.

### Creating a New Package

Use the scaffold script, which copies templates from `scripts/boilerplate` and personalizes the `name`:

```bash
# Unscoped package name
bash scripts/create-package.sh my-new-package

# Scoped package name (adds leading @ to npm name)
bash scripts/create-package.sh my-new-package --scoped
```

This creates:

- `packages/my-new-package/package.json` (ESM + CJS exports, tsup build, tsx dev, vitest run)
- `packages/my-new-package/tsconfig.json` (extends repo base)
- `packages/my-new-package/src/index.ts` (starter export)

Next steps:

```bash
npm run build
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
