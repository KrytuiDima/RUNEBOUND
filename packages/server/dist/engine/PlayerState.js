export class PlayerState {
    stats;
    currentMana;
    position;
    rotation;
    constructor(initialStats) { this.stats = initialStats; this.currentMana = this.calculateMaxMana(); this.position = { x: 0, y: 0, z: 0 }; this.rotation = 0; }
    calculateMaxMana() { return 80 + (this.stats.level * 12) + (this.stats.int * 4.5); }
    update(dt, inCombat) {
        const combatModifier = inCombat ? 0.34 : 1.0;
        const regen = 3.5 * (1 + this.stats.int * 0.008) * combatModifier;
        this.currentMana = Math.min(this.calculateMaxMana(), this.currentMana + regen * dt);
    }
}
//# sourceMappingURL=PlayerState.js.map