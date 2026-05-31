import { ServerGameLoop } from './engine/ServerGameLoop';
import { Quadtree } from './engine/Quadtree';
import { GestureValidator } from './validation/GestureValidator';
const quadtree = new Quadtree({ x: 0, y: 0, width: 1000, height: 1000 });
const validator = new GestureValidator([]);
const loop = new ServerGameLoop(60, (dt) => { /* Update logic */ });
console.log('Runebound Server Initialized at 60Hz');
loop.start();
