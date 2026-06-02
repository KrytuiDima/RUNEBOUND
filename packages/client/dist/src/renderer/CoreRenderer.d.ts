import * as THREE from 'three';
export declare class CoreRenderer {
    scene: THREE.Scene;
    camera: THREE.PerspectiveCamera;
    renderer: THREE.WebGLRenderer;
    private container;
    constructor(container: HTMLElement);
    render(): void;
}
