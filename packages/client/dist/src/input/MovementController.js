import * as THREE from 'three';
export class MovementController {
    player;
    keys = {};
    moveSpeed = 5;
    constructor(player) {
        this.player = player;
        window.addEventListener('keydown', (e) => this.keys[e.key.toLowerCase()] = true);
        window.addEventListener('keyup', (e) => this.keys[e.key.toLowerCase()] = false);
    }
    update(dt) {
        const dir = new THREE.Vector3();
        if (this.keys['w'])
            dir.z -= 1;
        if (this.keys['s'])
            dir.z += 1;
        if (this.keys['a'])
            dir.x -= 1;
        if (this.keys['d'])
            dir.x += 1;
        if (dir.length() > 0) {
            dir.normalize().multiplyScalar(this.moveSpeed * dt);
            this.player.position.add(dir);
        }
    }
}
//# sourceMappingURL=MovementController.js.map