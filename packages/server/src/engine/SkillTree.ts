import { InscriptionPath } from '@runebound/shared';
export interface SkillNode { id: string; path: InscriptionPath; rank: number; description: string; }
export class SkillTreeEngine {
  private nodes: SkillNode[] = [];
  constructor() { this.initializeNodes(); }
  private initializeNodes() {
    this.nodes.push({ id: 'flux_1', path: InscriptionPath.FLUX, rank: 1, description: 'Tolerance: 0.35' });
    this.nodes.push({ id: 'etcher_1', path: InscriptionPath.ETCHER, rank: 1, description: 'QS amplifier x1.1' });
    this.nodes.push({ id: 'geo_1', path: InscriptionPath.GEOMANCER, rank: 1, description: 'Grid snap (4x4)' });
  }
  public getAvailableNodes(path: InscriptionPath, currentRank: number): SkillNode[] {
    return this.nodes.filter(node => node.path === path && node.rank === currentRank + 1);
  }
}
