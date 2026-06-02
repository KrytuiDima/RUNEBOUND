import * as THREE from 'three';
export class CoreRenderer {
    scene;
    camera;
    renderer;
    container;
    constructor(container) {
        this.container = container;
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x06060e);
        this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.container.appendChild(this.renderer.domElement);
        const ambientLight = new THREE.AmbientLight(0x404040, 2);
        this.scene.add(ambientLight);
        const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
        directionalLight.position.set(5, 10, 7.5);
        this.scene.add(directionalLight);
        const gridHelper = new THREE.GridHelper(100, 100, 0x2a2a55, 0x181830);
        this.scene.add(gridHelper);
        window.addEventListener('resize', () => {
            this.camera.aspect = window.innerWidth / window.innerHeight;
            this.camera.updateProjectionMatrix();
            this.renderer.setSize(window.innerWidth, window.innerHeight);
        });
        this.camera.position.set(0, 5, 10);
        this.camera.lookAt(0, 0, 0);
    }
    render() {
        this.renderer.render(this.scene, this.camera);
    }
}
//# sourceMappingURL=CoreRenderer.js.map