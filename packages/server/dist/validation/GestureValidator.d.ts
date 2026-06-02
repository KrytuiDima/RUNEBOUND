import { Point, Template } from '@runebound/shared';
export interface StrokePacket {
    points: Point[];
    strokeDuration: number;
    inputEntropy: number;
    clientTs: number;
    playerId: string;
}
export declare class GestureValidator {
    private masterTemplates;
    constructor(templates: Template[]);
    validate(packet: StrokePacket, fluxRank?: number): {
        valid: boolean;
        reason: string;
        match?: undefined;
        confidence?: undefined;
        smoothness?: undefined;
        entropy?: undefined;
    } | {
        valid: boolean;
        match: string;
        confidence: number;
        smoothness: number;
        entropy: number;
        reason?: undefined;
    };
    private computeIntervalEntropy;
}
