import * as THREE from 'three';
import { CoreRenderer } from './renderer/CoreRenderer';
import { DrawingInputManager } from './input/DrawingStateMachine';
import { SpellEffectManager } from './effects/SpellEffectManager';
import { GestureProcessor } from './input/GestureProcessor';
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

  // Network Connection (Optional for local testing)
  let socket: WebSocket | null = null;
  try {
    socket = new WebSocket('ws://localhost:9001');
    socket.onopen = () => console.log('Connected to Server');
    socket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'CAST_RESULT' && data.success) {
        document.getElementById('hud-status')!.innerText = `SERVER: ${data.match}`;
        spellManager.createFireCircle(player.position.clone().add(new THREE.Vector3(0, 0, -2)), 2);
      }
    };
  } catch (e) {
    console.warn('Server not available, running in local-only mode');
  }

  function animate() {
    requestAnimationFrame(animate);
    spellManager.update(performance.now() * 0.001);
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

        if (socket && socket.readyState === WebSocket.OPEN) {
          const duration = points[points.length - 1].t - points[0].t;
          socket.send(JSON.stringify({
            type: 'STROKE_SUBMIT',
            points: points,
            strokeDuration: duration,
            inputEntropy: 2.0,
            clientTs: Date.now(),
            playerId: 'player1'
          }));
        }
      }
    }
  });

  window.addEventListener('pointermove', (e) => {
    inputManager.handlePointerMove(e.clientX, e.clientY);
  });

  animate();
  console.log('Runebound: Ready');

} catch (err) {
  console.error('Initialization failed:', err);
  const hud = document.getElementById('hud-status');
  if (hud) hud.innerText = 'ERROR: CHECK CONSOLE';
}
