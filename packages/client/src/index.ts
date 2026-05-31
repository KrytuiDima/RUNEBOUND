import * as THREE from 'three';
import { CoreRenderer } from './renderer/CoreRenderer';
import { DrawingInputManager } from './input/DrawingStateMachine';
import { SpellEffectManager } from './effects/SpellEffectManager';
const core = new CoreRenderer(document.getElementById('app') || document.body);
const spellManager = new SpellEffectManager(core.scene);
const player = new THREE.Object3D(); core.scene.add(player);
const inputManager = new DrawingInputManager(core.renderer, core.camera, player);
function animate() { requestAnimationFrame(animate); spellManager.update(performance.now() * 0.001); core.render(); }
window.addEventListener('keydown', (e) => { if (e.key === 'q') inputManager.startDrawing(); });
window.addEventListener('keyup', (e) => { if (e.key === 'q') console.log('Gesture captured:', inputManager.stopDrawing().length, 'points'); });
window.addEventListener('pointermove', (e) => inputManager.handlePointerMove(e.clientX, e.clientY));
animate();
