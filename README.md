# RUNEBOUND — Production Codebase

## How to Play (Development)

1. **Install Dependencies**:
   ```bash
   npm install
   ```
2. **Start Server**:
   ```bash
   cd packages/server
   npm run build
   npm start
   ```
3. **Start Client**:
   ```bash
   cd packages/client
   npm run dev
   ```
4. **Gameplay**:
   - **Hold 'Q'**: Enter Drawing Mode. A cyan line will follow your pointer.
   - **Draw**: Create a gesture (e.g., a circle) on the screen.
   - **Release 'Q'**: The gesture is processed. If successful, a magical fire circle appears in front of the player.

## Core Systems
- **Mathematical Gesture Recognition**: Optimized $1 Unistroke algorithm.
- **Visual Feedback**: Real-time 3D line drawing and shader-based spell effects.
- **Authoritative Server**: 60Hz loop, Quadtree collisions, and anti-cheat validation.
