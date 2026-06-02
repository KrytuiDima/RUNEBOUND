import * as THREE from 'three';
export declare const FIRE_RUNE_SHADER: {
    uniforms: {
        time: {
            value: number;
        };
        color: {
            value: THREE.Color;
        };
    };
    vertexShader: string;
    fragmentShader: string;
};
export declare class SpellEffectManager {
    private scene;
    constructor(scene: THREE.Scene);
    createFireCircle(position: THREE.Vector3, scale: number): THREE.Mesh<THREE.PlaneGeometry, THREE.ShaderMaterial, THREE.Object3DEventMap>;
    update(time: number): void;
}
