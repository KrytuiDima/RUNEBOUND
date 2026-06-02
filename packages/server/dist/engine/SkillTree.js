import { InscriptionPath } from '@runebound/shared';
export class SkillTreeEngine {
    nodes = [];
    constructor() { this.initializeNodes(); }
    initializeNodes() {
        this.nodes.push({ id: 'flux_1', path: InscriptionPath.FLUX, rank: 1, description: 'Tolerance: 0.35' });
        this.nodes.push({ id: 'etcher_1', path: InscriptionPath.ETCHER, rank: 1, description: 'QS amplifier x1.1' });
        this.nodes.push({ id: 'geo_1', path: InscriptionPath.GEOMANCER, rank: 1, description: 'Grid snap (4x4)' });
    }
    getAvailableNodes(path, currentRank) {
        return this.nodes.filter(node => node.path === path && node.rank === currentRank + 1);
    }
}
//# sourceMappingURL=SkillTree.js.map