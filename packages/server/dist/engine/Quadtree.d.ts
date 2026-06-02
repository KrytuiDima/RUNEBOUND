export interface Bounds {
    x: number;
    y: number;
    width: number;
    height: number;
}
export interface QuadtreeItem {
    id: string;
    x: number;
    y: number;
    width: number;
    height: number;
}
export declare class Quadtree {
    private bounds;
    private capacity;
    private items;
    private divided;
    private northwest?;
    private northeast?;
    private southwest?;
    private southeast?;
    constructor(bounds: Bounds, capacity?: number);
    insert(item: QuadtreeItem): boolean;
    private subdivide;
    private contains;
    query(range: Bounds, found?: QuadtreeItem[]): QuadtreeItem[];
    private intersects;
    private itemInRange;
    clear(): void;
}
