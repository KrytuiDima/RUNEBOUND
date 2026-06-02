import { Point } from '../types';
export declare const MAX_CURV_VAR = 2.8;
export declare function computeSmoothnessScore(points: Point[]): number;
export declare function computeClosureScore(points: Point[], isClosedForm: boolean, bboxDiagonal: number): number;
export declare function computeTempoScore(actualTimeMs: number, idealTimeMs: number): number;
export declare function computeQualityScore(smoothness: number, closure: number, tempo: number, confidence: number): number;
export declare function getQsDmgMultiplier(qs: number): number;
