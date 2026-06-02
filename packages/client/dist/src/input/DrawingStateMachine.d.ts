import * as THREE from 'three';
import { Point } from '@runebound/shared';
export declare class DrawingInputManager {
    private renderer;
    private camera;
    private player;
    private raycaster;
    private strokeBuffer;
    private isDrawing;
    private drawPlane;
    private lineGeometry;
    private line;
    private maxPoints;
    private currentLinePoints;
    constructor(renderer: THREE.WebGLRenderer, camera: THREE.PerspectiveCamera, player: THREE.Object3D);
    startDrawing(): void;
    stopDrawing(): Point[];
    private updateDrawingPlane;
    private clearLineMesh;
    private updateLineMesh;
    handlePointerMove(clientX: number, clientY: number): void;
}
