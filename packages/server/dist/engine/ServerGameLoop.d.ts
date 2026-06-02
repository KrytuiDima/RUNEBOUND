export declare class ServerGameLoop {
    private tickRate;
    private interval;
    private lastTickTime;
    private onTick;
    private timer;
    constructor(tickRate: number, onTick: (dt: number) => void);
    start(): void;
    stop(): void;
}
