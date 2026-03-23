{
  "name": "__NPM_NAME__",
  "version": "0.0.1",
  "types": "./dist/index.d.mts",
  "main": "./dist/index.mjs",
  "type": "module",
  "exports": {
    ".": {
      "types": "./dist/index.d.mts",
      "import": "./dist/index.mjs"
    }
  },
  "files": [
    "dist"
  ],
  "scripts": {
    "build": "tsdown src/index.ts --format esm --dts --clean",
    "dev": "tsx src/index.ts",
    "test": "vitest run --passWithNoTests"
  },
  "author": "",
  "license": "ISC",
  "description": "",
  "dependencies": {}
}


