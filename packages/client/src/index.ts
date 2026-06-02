import * as THREE from 'three';
import { CoreRenderer } from './renderer/CoreRenderer';
import { DrawingInputManager } from './input/DrawingStateMachine';
import { SpellEffectManager } from './effects/SpellEffectManager';
import { GestureProcessor } from './input/GestureProcessor';
import { MovementController } from './input/MovementController';
import { RUNE_TEMPLATES } from '@runebound/shared';

console.log('Runebound: Initializing...');

try {
  const container = document.getElementById('app');
  if (!container) throw new Error('Container #app not found');

  const core = new CoreRenderer(container);
  const spellManager = new SpellEffectManager(core.scene);
  const gestureProcessor = new GestureProcessor(RUNE_TEMPLATES);

  const playerGeo = new THREE.CapsuleGeometry(0.5, 1, 4, 8);
  const playerMat = new THREE.MeshStandardMaterial({ color: 0x00d4ff });
  const player = new THREE.Mesh(playerGeo, playerMat);
  player.position.y = 1;
  core.scene.add(player);

  const inputManager = new DrawingInputManager(core.renderer, core.camera, player);
  const moveController = new MovementController(player);

  let lastTime = performance.now();

  function animate() {
    requestAnimationFrame(animate);
    const time = performance.now();
    const dt = (time - lastTime) / 1000;
    lastTime = time;

    moveController.update(dt);
    spellManager.update(time * 0.001);
    core.render();
  }

  window.addEventListener('keydown', (e) => {
    if (e.key.toLowerCase() === 'q') {
      inputManager.startDrawing();
      document.getElementById('hud-status')!.innerText = "DRAWING...";
    }
  });

  window.addEventListener('keyup', (e) => {
    if (e.key.toLowerCase() === 'q') {
      const points = inputManager.stopDrawing();
      if (points.length > 5) {
        gestureProcessor.processGesture(points).then(result => {
          document.getElementById('hud-status')!.innerText = `LOCAL: ${result.match}`;
          if (result.match !== 'UNRECOGNIZED') {
            spellManager.createFireCircle(player.position.clone().add(new THREE.Vector3(0, 0, -2)), 2);
          }
        });
      } else {
        document.getElementById('hud-status')!.innerText = "IDLE";
      }
    }
  });

  // Critical: Listen on window to capture moves even if mouse button is up/down
  window.addEventListener('pointermove', (e) => {
    inputManager.handlePointerMove(e.clientX, e.clientY);
  });

  animate();
  console.log('Runebound: Ready');

} catch (err) {
  console.error('Initialization failed:', err);
}
