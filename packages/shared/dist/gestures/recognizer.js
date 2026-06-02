const N = 32;
const SQUARE_SIZE = 250.0;
const PHI = 0.5 * (-1.0 + Math.sqrt(5.0));
const ANGLE_RANGE = 45;
const ANGLE_PRECISION = 2;
const EARLY_OUT_SCORE = 0.95;
const MATCH_THRESHOLD = 0.65;
export function recognize(points, templates) {
    let processedPoints = resample(points, N);
    const radians = indicativeAngle(processedPoints);
    processedPoints = rotateBy(processedPoints, -radians);
    processedPoints = scaleTo(processedPoints, SQUARE_SIZE);
    processedPoints = translateTo(processedPoints, { x: 0, y: 0 });
    let best = { score: -Infinity, name: 'NONE' };
    for (const tmpl of templates) {
        if (best.score >= EARLY_OUT_SCORE)
            break;
        const d = distanceAtBestAngle(processedPoints, tmpl.points, -ANGLE_RANGE, +ANGLE_RANGE, ANGLE_PRECISION);
        const score = 1.0 - (d / (0.5 * Math.sqrt(2 * SQUARE_SIZE ** 2)));
        if (score > best.score)
            best = { score, name: tmpl.name };
    }
    return best.score >= MATCH_THRESHOLD ? { match: best.name, confidence: best.score } : { match: 'UNRECOGNIZED', confidence: best.score };
}
function resample(points, n) {
    const I = pathLength(points) / (n - 1);
    let D = 0.0;
    const newPoints = [points[0]];
    const pts = [...points];
    for (let i = 1; i < pts.length; i++) {
        const d = distance(pts[i - 1], pts[i]);
        if (D + d >= I) {
            const q = { x: pts[i - 1].x + ((I - D) / d) * (pts[i].x - pts[i - 1].x), y: pts[i - 1].y + ((I - D) / d) * (pts[i].y - pts[i - 1].y), t: pts[i].t };
            newPoints.push(q);
            pts.splice(i, 0, q);
            D = 0.0;
        }
        else
            D += d;
    }
    if (newPoints.length === n - 1)
        newPoints.push(pts[pts.length - 1]);
    return newPoints;
}
function indicativeAngle(points) {
    const centroid = getCentroid(points);
    return Math.atan2(centroid.y - points[0].y, centroid.x - points[0].x);
}
function rotateBy(points, radians) {
    const centroid = getCentroid(points);
    const cos = Math.cos(radians);
    const sin = Math.sin(radians);
    return points.map(p => ({
        x: (p.x - centroid.x) * cos - (p.y - centroid.y) * sin + centroid.x,
        y: (p.x - centroid.x) * sin + (p.y - centroid.y) * cos + centroid.y,
        t: p.t
    }));
}
function scaleTo(points, size) {
    const bbox = getBoundingBox(points);
    return points.map(p => ({ x: p.x * (size / bbox.width), y: p.y * (size / bbox.height), t: p.t }));
}
function translateTo(points, pt) {
    const centroid = getCentroid(points);
    return points.map(p => ({ x: p.x + pt.x - centroid.x, y: p.y + pt.y - centroid.y, t: p.t }));
}
function distanceAtBestAngle(pts, tmpl, a, b, threshold) {
    let x1 = a + PHI * (b - a);
    let x2 = b - PHI * (b - a);
    let f1 = pathDist(rotateBy(pts, x1), tmpl);
    let f2 = pathDist(rotateBy(pts, x2), tmpl);
    while (Math.abs(b - a) > threshold) {
        if (f1 < f2) {
            b = x2;
            x2 = x1;
            f2 = f1;
            x1 = a + PHI * (b - a);
            f1 = pathDist(rotateBy(pts, x1), tmpl);
        }
        else {
            a = x1;
            x1 = x2;
            f1 = f2;
            x2 = b - PHI * (b - a);
            f2 = pathDist(rotateBy(pts, x2), tmpl);
        }
    }
    return Math.min(f1, f2);
}
function pathDist(pts1, pts2) {
    let d = 0.0;
    for (let i = 0; i < pts1.length; i++)
        d += distance(pts1[i], pts2[i]);
    return d / pts1.length;
}
function pathLength(points) {
    let d = 0.0;
    for (let i = 1; i < points.length; i++)
        d += distance(points[i - 1], points[i]);
    return d;
}
function distance(p1, p2) { return Math.sqrt((p2.x - p1.x) ** 2 + (p2.y - p1.y) ** 2); }
function getCentroid(points) {
    let x = 0, y = 0;
    for (const p of points) {
        x += p.x;
        y += p.y;
    }
    return { x: x / points.length, y: y / points.length };
}
function getBoundingBox(points) {
    let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
    for (const p of points) {
        minX = Math.min(minX, p.x);
        maxX = Math.max(maxX, p.x);
        minY = Math.min(minY, p.y);
        maxY = Math.max(maxY, p.y);
    }
    return { width: maxX - minX, height: maxY - minY };
}
//# sourceMappingURL=recognizer.js.map