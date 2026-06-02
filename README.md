# RUNEBOUND — Production Codebase

## Troubleshooting "Failed to resolve entry for package 'three'"

This error usually happens if `node_modules` are not properly linked in the monorepo.

**Run these commands to fix:**
```bash
# 1. Clear everything
rm -rf node_modules package-lock.json packages/*/node_modules

# 2. Install from root
npm install

# 3. Start client
cd packages/client
npm run dev
```

## How to Play

- **Hold 'Q'**: Enter Drawing Mode (Cyan line appears).
- **Draw**: Make a Circle or Triangle.
- **Release 'Q'**: Casting occurs.
