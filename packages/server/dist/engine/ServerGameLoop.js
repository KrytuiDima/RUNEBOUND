export class ServerGameLoop {
    tickRate;
    interval;
    lastTickTime;
    onTick;
    timer = null;
    constructor(tickRate, onTick) {
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
    stop() { if (this.timer) {
        clearInterval(this.timer);
        this.timer = null;
    } }
}
//# sourceMappingURL=ServerGameLoop.js.map