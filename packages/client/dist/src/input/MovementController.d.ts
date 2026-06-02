import * as THREE from 'three';
export declare class MovementController {
    private player;
    private keys;
    private moveSpeed;
    constructor(player: THREE.Object3D);
    update(dt: number): void;
}
