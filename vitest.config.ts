import { defineConfig } from 'vitest/config'
import { config } from 'dotenv'

// Load environment variables from .env file
config()

export default defineConfig({
  test: {
    include: ['./**/*.test.ts'],
    exclude: ['**/dist/**', '**/node_modules/**', 'packages/pipeline/tests/**'],
    environment: 'node',
    coverage: {
      reporter: ['text', 'html'],
      exclude: ['**/dist/**', 'vitest.config.ts', '**/node_modules/**'],
    },
  },
})
