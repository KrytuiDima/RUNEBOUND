export class Quadtree {
    bounds;
    capacity;
    items = [];
    divided = false;
    northwest;
    northeast;
    southwest;
    southeast;
    constructor(bounds, capacity = 4) { this.bounds = bounds; this.capacity = capacity; }
    insert(item) {
        if (!this.contains(item))
            return false;
        if (this.items.length < this.capacity) {
            this.items.push(item);
            return true;
        }
        if (!this.divided)
            this.subdivide();
        return (this.northwest.insert(item) || this.northeast.insert(item) || this.southwest.insert(item) || this.southeast.insert(item));
    }
    subdivide() {
        const { x, y, width, height } = this.bounds;
        const w = width / 2;
        const h = height / 2;
        this.northwest = new Quadtree({ x, y, width: w, height: h }, this.capacity);
        this.northeast = new Quadtree({ x: x + w, y, width: w, height: h }, this.capacity);
        this.southwest = new Quadtree({ x, y: y + h, width: w, height: h }, this.capacity);
        this.southeast = new Quadtree({ x: x + w, y: y + h, width: w, height: h }, this.capacity);
        this.divided = true;
    }
    contains(item) { return (item.x >= this.bounds.x && item.x <= this.bounds.x + this.bounds.width && item.y >= this.bounds.y && item.y <= this.bounds.y + this.bounds.height); }
    query(range, found = []) {
        if (!this.intersects(range))
            return found;
        for (const item of this.items) {
            if (this.itemInRange(item, range))
                found.push(item);
        }
        if (this.divided) {
            this.northwest.query(range, found);
            this.northeast.query(range, found);
            this.southwest.query(range, found);
            this.southeast.query(range, found);
        }
        return found;
    }
    intersects(range) { return !(range.x > this.bounds.x + this.bounds.width || range.x + range.width < this.bounds.x || range.y > this.bounds.y + this.bounds.height || range.y + range.height < this.bounds.y); }
    itemInRange(item, range) { return (item.x >= range.x && item.x <= range.x + range.width && item.y >= range.y && item.y <= range.y + range.height); }
    clear() { this.items = []; this.divided = false; this.northwest = undefined; this.northeast = undefined; this.southwest = undefined; this.southeast = undefined; }
}
//# sourceMappingURL=Quadtree.js.map