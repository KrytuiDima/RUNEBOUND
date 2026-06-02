import { Point, Template } from '@runebound/shared';
export declare class GestureProcessor {
    private templates;
    constructor(templates: Template[]);
    processGesture(points: Point[]): Promise<import("@runebound/shared").RecognitionResult>;
}
