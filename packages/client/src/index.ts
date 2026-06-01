import * as THREE from 'three';
import { CoreRenderer } from './renderer/CoreRenderer';
import { DrawingInputManager } from './input/DrawingStateMachine';
import { SpellEffectManager } from './effects/SpellEffectManager';
import { GestureProcessor } from './input/GestureProcessor';
import { RUNE_TEMPLATES } from '@runebound/shared';

const core = new CoreRenderer(document.getElementById('app') || document.body);
const spellManager = new SpellEffectManager(core.scene);
const gestureProcessor = new GestureProcessor(RUNE_TEMPLATES);

const playerGeo = new THREE.CapsuleGeometry(0.5, 1, 4, 8);
const playerMat = new THREE.MeshStandardMaterial({ color: 0x00d4ff });
const player = new THREE.Mesh(playerGeo, playerMat);
player.position.y = 1;
core.scene.add(player);

const inputManager = new DrawingInputManager(core.renderer, core.camera, player);

// Network Connection
const socket = new WebSocket('ws://localhost:9001');

socket.onopen = () => console.log('Connected to Server');
socket.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Server authoritative response:', data);
  if (data.type === 'CAST_RESULT') {
    if (data.success) {
      document.getElementById('hud-status')!.innerText = `SERVER VALIDATED: ${data.match} (${Math.round(data.confidence * 100)}%)`;
      spellManager.createFireCircle(player.position.clone().add(new THREE.Vector3(0, 0, -2)), 2);
    } else {
      document.getElementById('hud-status')!.innerText = `SERVER REJECTED: ${data.match || 'REASON: LOW_QUALITY'}`;
    }
  }
};

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
      // Local Prediction
      gestureProcessor.processGesture(points).then(result => {
        console.log('Local Prediction:', result);
        document.getElementById('hud-status')!.innerText = `PREDICTING: ${result.match}...`;
      });

      // Authoritative Submission
      const duration = points[points.length - 1].t - points[0].t;
      socket.send(JSON.stringify({
        type: 'STROKE_SUBMIT',
        points: points,
        strokeDuration: duration,
        inputEntropy: 2.0, // Should be calculated
        clientTs: Date.now(),
        playerId: 'player1'
      }));
    }
  }
});

window.addEventListener('pointermove', (e) => {
  inputManager.handlePointerMove(e.clientX, e.clientY);
});

animate();
