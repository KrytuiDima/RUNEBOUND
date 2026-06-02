import * as THREE from 'three';
export const FIRE_RUNE_SHADER = {
  uniforms: { time: { value: 0 }, color: { value: new THREE.Color(0xff4400) } },
  vertexShader: `varying vec2 vUv; void main() { vUv = uv; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }`,
  fragmentShader: `uniform float time; uniform vec3 color; varying vec2 vUv; void main() { float pulse = 0.5 + 0.5 * sin(time * 5.0); float dist = distance(vUv, vec2(0.5)); float mask = smoothstep(0.5, 0.45, dist); gl_FragColor = vec4(color * pulse, mask); }`
};
export class SpellEffectManager {
  private scene: THREE.Scene; constructor(scene: THREE.Scene) { this.scene = scene; }
  createFireCircle(position: THREE.Vector3, scale: number) {
    const mesh = new THREE.Mesh(new THREE.PlaneGeometry(1, 1), new THREE.ShaderMaterial({ uniforms: THREE.UniformsUtils.clone(FIRE_RUNE_SHADER.uniforms), vertexShader: FIRE_RUNE_SHADER.vertexShader, fragmentShader: FIRE_RUNE_SHADER.fragmentShader, transparent: true, side: THREE.DoubleSide }));
    mesh.position.copy(position); mesh.scale.set(scale, scale, scale); this.scene.add(mesh); return mesh;
  }
  update(time: number) { this.scene.traverse((obj) => { if (obj instanceof THREE.Mesh && obj.material instanceof THREE.ShaderMaterial) { if (obj.material.uniforms.time) obj.material.uniforms.time.value = time; } }); }
}
