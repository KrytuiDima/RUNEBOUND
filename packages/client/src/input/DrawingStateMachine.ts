import * as THREE from 'three';
import { Point } from '@runebound/shared';
export class DrawingInputManager {
  private renderer: THREE.WebGLRenderer; private camera: THREE.PerspectiveCamera; private player: THREE.Object3D;
  private raycaster: THREE.Raycaster; private strokeBuffer: Point[] = []; private isDrawing: boolean = false; private drawPlane: THREE.Plane;
  constructor(renderer: THREE.WebGLRenderer, camera: THREE.PerspectiveCamera, player: THREE.Object3D) { this.renderer = renderer; this.camera = camera; this.player = player; this.raycaster = new THREE.Raycaster(); this.drawPlane = new THREE.Plane(); }
  public startDrawing() { this.isDrawing = true; this.strokeBuffer = []; this.updateDrawingPlane(); }
  public stopDrawing(): Point[] { this.isDrawing = false; return [...this.strokeBuffer]; }
  private updateDrawingPlane() {
    const dir = new THREE.Vector3(); this.camera.getWorldDirection(dir);
    const planeOrigin = this.player.position.clone().addScaledVector(dir, 1.8).setY(this.player.position.y + 1.4);
    this.drawPlane.setFromNormalAndCoplanarPoint(dir.negate(), planeOrigin);
  }
  public handlePointerMove(clientX: number, clientY: number) {
    if (!this.isDrawing) return;
    const ndc = new THREE.Vector2((clientX / window.innerWidth) * 2 - 1, -(clientY / window.innerHeight) * 2 + 1);
    this.raycaster.setFromCamera(ndc, this.camera);
    const worldPt = new THREE.Vector3(); this.raycaster.ray.intersectPlane(this.drawPlane, worldPt);
    if (worldPt) { const localPt = worldPt.applyMatrix4(this.player.matrixWorld.clone().invert()); this.strokeBuffer.push({ x: localPt.x, y: localPt.y, t: performance.now() }); }
  }
}
