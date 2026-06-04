# Runebound: 3D Magic RPG

Runebound is a production-grade 3D Magic RPG built in Roblox with a focus on gesture-based spellcasting and deep RPG mechanics.

## Key Features
- **Gesture Recognition**: Capture 2D drawing gestures on screen and translate them into 3D spells using a $1 Unistroke Recognizer.
- **Spell Combination System**: Over 100 unique spells derived from base runes and elemental combinations.
- **Dynamic RPG Systems**: Individual skill trees, crafting (wands, stones), and attribute-based scaling.
- **Game Modes**: Solo/Co-op instanced dungeons, Open-world PvP, and high-stakes Resource Wager Duels.
- **Anti-Cheat**: Strict server-side validation of stroke telemetry, including velocity entropy and time-delta checks.

## Project Structure
- `src/shared`: Replicated modules (SpellRegistry, CraftingRecipes, Types).
- `src/client`: Client-side controllers (DrawingController, GestureRecognizer, VFXManager).
- `src/server`: Server-side logic (SpellServer, CombatEngine, GameModeManager, DataManager).

## Setup Instructions

### 1. Prerequisite: Rojo
Ensure you have **Rojo** installed. You can install it via VS Code extensions or as a standalone CLI tool.

### 2. Connect Rojo to Roblox Studio
1. Open your Roblox Studio place.
2. Install the **Rojo Plugin** in Roblox Studio.
3. In your terminal, navigate to the `Runebound/` directory and run:
   ```bash
   rojo serve
   ```
4. In Roblox Studio, open the Rojo plugin and click **Connect**.

### 3. File Synchronization
Rojo will now synchronize all files in `src/` to their respective locations in the Roblox DataModel as defined in `default.project.json`.

## Technical Details
- **Gesture Algorithm**: Implements the $1 Unistroke algorithm with resampling, rotation normalization, and bounding-box scaling.
- **Networking**: Uses a `RemoteEvent` named `CastSpellEvent` to transmit raw point telemetry for server-side verification.
- **Performance**: Spatial partitioning (`GetPartBoundsInRadius`) is utilized for efficient AOE damage calculation.
