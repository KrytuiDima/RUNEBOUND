import * as THREE from 'three';
export class CoreRenderer {
  public scene: THREE.Scene; public camera: THREE.PerspectiveCamera; public renderer: THREE.WebGLRenderer; private container: HTMLElement;
  constructor(container: HTMLElement) {
    this.container = container; this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    this.renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.container.appendChild(this.renderer.domElement);
    window.addEventListener('resize', () => { this.camera.aspect = window.innerWidth / window.innerHeight; this.camera.updateProjectionMatrix(); this.renderer.setSize(window.innerWidth, window.innerHeight); });
    this.camera.position.set(0, 1.6, 5);
  }
  public render() { this.renderer.render(this.scene, this.camera); }
}
