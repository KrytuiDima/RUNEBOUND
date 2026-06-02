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

    this.lineGeometry = new THREE.BufferGeometry();
    const positions = new Float32Array(this.maxPoints * 3);
    this.lineGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    this.line = new THREE.Line(this.lineGeometry, new THREE.LineBasicMaterial({ color: 0x00d4ff, linewidth: 4, depthTest: false }));
    this.line.renderOrder = 999;
    this.line.visible = false;
    this.line.frustumCulled = false;

    // Line is added to the scene globally to avoid complex local-to-world logic during drawing
    player.parent?.add(this.line) || player.add(this.line);
  }

  public startDrawing() {
    this.isDrawing = true;
    this.strokeBuffer = [];
    this.currentLinePoints = [];
    this.updateDrawingPlane();
    this.line.visible = true;
    this.clearLineMesh();
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

  private clearLineMesh() {
    const positions = this.line.geometry.attributes.position.array as Float32Array;
    positions.fill(0);
    this.line.geometry.attributes.position.needsUpdate = true;
    this.line.geometry.setDrawRange(0, 0);
  }

  private updateLineMesh() {
    const positions = this.line.geometry.attributes.position.array as Float32Array;
    for (let i = 0; i < this.currentLinePoints.length; i++) {
      positions[i * 3] = this.currentLinePoints[i].x;
      positions[i * 3 + 1] = this.currentLinePoints[i].y;
      positions[i * 3 + 2] = this.currentLinePoints[i].z;
    }
    this.line.geometry.attributes.position.needsUpdate = true;
    this.line.geometry.setDrawRange(0, this.currentLinePoints.length);
  }

  public handlePointerMove(clientX: number, clientY: number) {
    if (!this.isDrawing) return;

    // Use renderer's canvas rect for accurate NDC
    const rect = this.renderer.domElement.getBoundingClientRect();
    const x = ((clientX - rect.left) / rect.width) * 2 - 1;
    const y = -((clientY - rect.top) / rect.height) * 2 + 1;

    this.raycaster.setFromCamera({ x, y }, this.camera);

    const worldPt = new THREE.Vector3();
    const intersection = this.raycaster.ray.intersectPlane(this.drawPlane, worldPt);

    if (intersection) {
      // For recognition, we need local coordinates
      const invMatrix = this.player.matrixWorld.clone().invert();
      const localPt = worldPt.clone().applyMatrix4(invMatrix);

      this.strokeBuffer.push({ x: localPt.x, y: localPt.y, t: performance.now() });

      if (this.currentLinePoints.length < this.maxPoints) {
        this.currentLinePoints.push(worldPt.clone());
        this.updateLineMesh();
      }
    }
  }
}
