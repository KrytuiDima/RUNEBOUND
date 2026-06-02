import { PlayerStats } from '@runebound/shared';
export class PlayerState {
  public stats: PlayerStats; public currentMana: number; public position: { x: number; y: number; z: number }; public rotation: number;
  constructor(initialStats: PlayerStats) { this.stats = initialStats; this.currentMana = this.calculateMaxMana(); this.position = { x: 0, y: 0, z: 0 }; this.rotation = 0; }
  calculateMaxMana(): number { return 80 + (this.stats.level * 12) + (this.stats.int * 4.5); }
  update(dt: number, inCombat: boolean) {
    const combatModifier = inCombat ? 0.34 : 1.0;
    const regen = 3.5 * (1 + this.stats.int * 0.008) * combatModifier;
    this.currentMana = Math.min(this.calculateMaxMana(), this.currentMana + regen * dt);
  }
}
