export class ServerGameLoop {
  private tickRate: number;
  private interval: number;
  private lastTickTime: number;
  private onTick: (dt: number) => void;
  private timer: NodeJS.Timeout | null = null;
  constructor(tickRate: number, onTick: (dt: number) => void) {
    this.tickRate = tickRate;
    this.interval = 1000 / tickRate;
    this.onTick = onTick;
    this.lastTickTime = Date.now();
  }
  start() {
    this.lastTickTime = Date.now();
    this.timer = setInterval(() => {
      const now = Date.now();
      const dt = (now - this.lastTickTime) / 1000;
      this.lastTickTime = now;
      this.onTick(dt);
    }, this.interval);
  }
  stop() { if (this.timer) { clearInterval(this.timer); this.timer = null; } }
}
