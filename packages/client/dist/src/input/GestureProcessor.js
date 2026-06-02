import { recognize } from '@runebound/shared';
export class GestureProcessor {
    templates;
    constructor(templates) {
        this.templates = templates;
    }
    async processGesture(points) {
        if (points.length < 5)
            return { match: 'NONE', confidence: 0 };
        return recognize(points, this.templates);
    }
}
//# sourceMappingURL=GestureProcessor.js.map