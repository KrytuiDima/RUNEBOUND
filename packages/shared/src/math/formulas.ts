import { Point } from '../types';

export const MAX_CURV_VAR = 2.8;

export function computeSmoothnessScore(points: Point[]): number {
  if (points.length < 3) return 1.0;
  const angles: number[] = [];
  for (let i = 1; i < points.length - 1; i++) {
    const v1 = { x: points[i].x - points[i - 1].x, y: points[i].y - points[i - 1].y };
    const v2 = { x: points[i + 1].x - points[i].x, y: points[i + 1].y - points[i].y };
    const dot = v1.x * v2.x + v1.y * v2.y;
    const mag = Math.sqrt((v1.x ** 2 + v1.y ** 2) * (v2.x ** 2 + v2.y ** 2)) || 1e-6;
    angles.push(Math.acos(Math.max(-1, Math.min(1, dot / mag))));
  }
  const mean = angles.reduce((s, v) => s + v, 0) / angles.length;
  const sigma2 = angles.reduce((s, v) => s + (v - mean) ** 2, 0) / angles.length;
  return Math.max(0, 1 - (sigma2 / MAX_CURV_VAR));
}

export function computeClosureScore(points: Point[], isClosedForm: boolean, bboxDiagonal: number): number {
  if (!isClosedForm) return 1.0;
  if (points.length < 2) return 0.0;
  const p0 = points[0];
  const pn = points[points.length - 1];
  const dist = Math.sqrt((pn.x - p0.x) ** 2 + (pn.y - p0.y) ** 2);
  return 1.0 - Math.min(dist / bboxDiagonal, 1.0);
}

export function computeTempoScore(actualTimeMs: number, idealTimeMs: number): number {
  const lambda = 3.0;
  return Math.exp(-lambda * Math.abs(actualTimeMs / 1000 - idealTimeMs / 1000) / (idealTimeMs / 1000));
}

export function computeQualityScore(smoothness: number, closure: number, tempo: number, confidence: number): number {
  const normalizedConf = Math.max(0, (confidence - 0.65) / 0.35);
  return (smoothness * 0.30) + (closure * 0.20) + (tempo * 0.30) + (normalizedConf * 0.20);
}

export function getQsDmgMultiplier(qs: number): number {
  if (qs >= 0.93) return 1.80;
  if (qs >= 0.85) return 1.45;
  if (qs >= 0.75) return 1.20;
  if (qs >= 0.65) return 1.00;
  if (qs >= 0.55) return 0.85;
  if (qs >= 0.40) return 0.65;
  return 0.40;
}
