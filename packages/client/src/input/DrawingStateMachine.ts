import * as THREE from 'three';
import { Point } from '@runebound/shared';

export class DrawingInputManager {
  private renderer: THREE.WebGLRenderer;
  private camera: THREE.PerspectiveCamera;
  private player: THREE.Object3D;
  private raycaster: THREE.Raycaster;
  private strokeBuffer: Point[] = [];
  private isDrawing: boolean = false;
  private drawPlane: THREE.Plane;

  // Visual Feedback
  private lineGeometry: THREE.BufferGeometry;
  private line: THREE.Line;
  private maxPoints = 256;
  private currentLinePoints: THREE.Vector3[] = [];

  constructor(renderer: THREE.WebGLRenderer, camera: THREE.PerspectiveCamera, player: THREE.Object3D) {
    this.renderer = renderer;
    this.camera = camera;
    this.player = player;
    this.raycaster = new THREE.Raycaster();
    this.drawPlane = new THREE.Plane();

    // Initialize line for visual feedback
    this.lineGeometry = new THREE.BufferGeometry();
    const positions = new Float32Array(this.maxPoints * 3);
    this.lineGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    this.line = new THREE.Line(this.lineGeometry, new THREE.LineBasicMaterial({ color: 0x00d4ff, linewidth: 2 }));
    this.line.frustumCulled = false;
    player.add(this.line); // Attach to player for local space rendering
  }

  public startDrawing() {
    this.isDrawing = true;
    this.strokeBuffer = [];
    this.currentLinePoints = [];
    this.updateDrawingPlane();
    this.updateLineMesh();
    this.line.visible = true;
  }

  public stopDrawing(): Point[] {
    this.isDrawing = false;
    this.line.visible = false;
    return [...this.strokeBuffer];
  }

  private updateDrawingPlane() {
    const dir = new THREE.Vector3();
    this.camera.getWorldDirection(dir);
    const planeOrigin = this.player.position.clone().addScaledVector(dir, 1.8).setY(this.player.position.y + 1.4);
    this.drawPlane.setFromNormalAndCoplanarPoint(dir.negate(), planeOrigin);
  }

  private updateLineMesh() {
    const positions = this.line.geometry.attributes.position.array as Float32Array;
    for (let i = 0; i < this.maxPoints; i++) {
      if (i < this.currentLinePoints.length) {
        positions[i * 3] = this.currentLinePoints[i].x;
        positions[i * 3 + 1] = this.currentLinePoints[i].y;
        positions[i * 3 + 2] = this.currentLinePoints[i].z;
      } else {
        // Hide unused points
        positions[i * 3] = 0;
        positions[i * 3 + 1] = 0;
        positions[i * 3 + 2] = 0;
      }
    }
    this.line.geometry.attributes.position.needsUpdate = true;
    this.line.geometry.setDrawRange(0, this.currentLinePoints.length);
  }

  public handlePointerMove(clientX: number, clientY: number) {
    if (!this.isDrawing) return;

    const ndc = new THREE.Vector2((clientX / window.innerWidth) * 2 - 1, -(clientY / window.innerHeight) * 2 + 1);
    this.raycaster.setFromCamera(ndc, this.camera);

    const worldPt = new THREE.Vector3();
    this.raycaster.ray.intersectPlane(this.drawPlane, worldPt);

    if (worldPt) {
      const invMatrix = this.player.matrixWorld.clone().invert();
      const localPt = worldPt.applyMatrix4(invMatrix);

      this.strokeBuffer.push({ x: localPt.x, y: localPt.y, t: performance.now() });

      if (this.currentLinePoints.length < this.maxPoints) {
        this.currentLinePoints.push(localPt.clone());
        this.updateLineMesh();
      }
    }
  }
}
