import { PlayerStats } from '@runebound/shared';
export declare class PlayerState {
    stats: PlayerStats;
    currentMana: number;
    position: {
        x: number;
        y: number;
        z: number;
    };
    rotation: number;
    constructor(initialStats: PlayerStats);
    calculateMaxMana(): number;
    update(dt: number, inCombat: boolean): void;
}
