import * as uWS from 'uWebSockets.js';
import { GestureValidator, StrokePacket } from './validation/GestureValidator';
import { RUNE_TEMPLATES } from '@runebound/shared';
import { ServerGameLoop } from './engine/ServerGameLoop';

const validator = new GestureValidator(RUNE_TEMPLATES);
const port = 9001;

uWS.App().ws('/*', {
  open: (ws) => console.log('Client connected'),
  message: (ws, message) => {
    try {
      const packet = JSON.parse(Buffer.from(message).toString());
      if (packet.type === 'STROKE_SUBMIT') {
        const result = validator.validate(packet as StrokePacket);
        ws.send(JSON.stringify({ type: 'CAST_RESULT', success: result.valid, match: result.match, confidence: result.confidence }));
      }
    } catch (e) {}
  }
}).listen(port, (token) => {
  if (token) console.log(`Server listening on port ${port}`);
});

new ServerGameLoop(60, () => {}).start();
