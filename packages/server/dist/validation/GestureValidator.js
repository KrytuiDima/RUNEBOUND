import { recognize, computeSmoothnessScore } from '@runebound/shared';
export class GestureValidator {
    masterTemplates;
    constructor(templates) { this.masterTemplates = templates; }
    validate(packet, fluxRank = 0) {
        const { points, strokeDuration, inputEntropy } = packet;
        if (points.length < 4 || points.length > 256)
            return { valid: false, reason: 'POINT_COUNT_OOBOUNDS' };
        const pathMult = fluxRank >= 5 ? 0.70 : 1.00;
        const minDuration = points.length * 3.5 * pathMult;
        if (strokeDuration < minDuration)
            return { valid: false, reason: 'SUPERHUMAN_SPEED' };
        const declaredDelta = points[points.length - 1].t - points[0].t;
        if (Math.abs(declaredDelta - strokeDuration) > 50)
            return { valid: false, reason: 'TIMESTAMP_TAMPER' };
        const serverEntropy = this.computeIntervalEntropy(points);
        if (Math.abs(serverEntropy - inputEntropy) > 0.3)
            return { valid: false, reason: 'ENTROPY_MISMATCH' };
        if (serverEntropy < 1.2)
            return { valid: false, reason: 'MACRO_SIGNATURE' };
        const result = recognize(points, this.masterTemplates);
        const smoothness = computeSmoothnessScore(points);
        return { valid: true, match: result.match, confidence: result.confidence, smoothness, entropy: serverEntropy };
    }
    computeIntervalEntropy(points) {
        const deltas = [];
        for (let i = 1; i < points.length; i++)
            deltas.push(points[i].t - points[i - 1].t);
        const bins = new Map();
        deltas.forEach(d => { const bin = Math.floor(d / 5); bins.set(bin, (bins.get(bin) || 0) + 1); });
        const total = deltas.length;
        let h = 0;
        bins.forEach(count => { const p = count / total; h -= p * Math.log2(p); });
        return h;
    }
}
//# sourceMappingURL=GestureValidator.js.map