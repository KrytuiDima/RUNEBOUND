import { Point, recognize, Template } from '@runebound/shared';

export class GestureProcessor {
  private templates: Template[];

  constructor(templates: Template[]) {
    this.templates = templates;
  }

  public async processGesture(points: Point[]) {
    if (points.length < 5) return { match: 'NONE', confidence: 0 };
    return recognize(points, this.templates);
  }
}
