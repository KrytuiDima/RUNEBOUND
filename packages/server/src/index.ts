import * as uWS from 'uWebSockets.js';
import { GestureValidator, StrokePacket } from './validation/GestureValidator';
import { RUNE_TEMPLATES } from '@runebound/shared';
import { ServerGameLoop } from './engine/ServerGameLoop';

const validator = new GestureValidator(RUNE_TEMPLATES);
const port = 9001;

const app = uWS.App().ws('/*', {
  compression: uWS.SHARED_COMPRESSOR,
  maxPayloadLength: 16 * 1024 * 1024,
  idleTimeout: 10,

  open: (ws) => {
    console.log('Client connected');
  },

  message: (ws, message, isBinary) => {
    try {
      const text = Buffer.from(message).toString();
      const packet = JSON.parse(text);

      if (packet.type === 'STROKE_SUBMIT') {
        const result = validator.validate(packet as StrokePacket);
        console.log('Validation Result:', result);

        ws.send(JSON.stringify({
          type: 'CAST_RESULT',
          success: result.valid,
          match: result.match,
          confidence: result.confidence
        }));
      }
    } catch (e) {
      console.error('Failed to process message', e);
    }
  }
}).listen(port, (token) => {
  if (token) {
    console.log(`Runebound Server listening on port ${port}`);
  } else {
    console.log('Failed to listen on port ' + port);
  }
});

const gameLoop = new ServerGameLoop(60, (dt) => {
  // Broadcaster for player positions would go here
});
gameLoop.start();
