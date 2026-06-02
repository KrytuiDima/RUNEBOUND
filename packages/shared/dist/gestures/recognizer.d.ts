import { Point, RecognitionResult } from '../types';
export interface Template {
    name: string;
    points: Point[];
}
export declare function recognize(points: Point[], templates: Template[]): RecognitionResult;
