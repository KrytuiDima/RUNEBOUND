import { Point, recognize, Template } from '@runebound/shared';
export class GestureProcessor {
  private templates: Template[]; constructor(templates: Template[]) { this.templates = templates; }
  public async processGesture(points: Point[]) { return new Promise((resolve) => { setTimeout(() => resolve(recognize(points, this.templates)), 5); }); }
}
