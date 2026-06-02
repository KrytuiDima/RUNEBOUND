import { InscriptionPath } from '@runebound/shared';
export interface SkillNode {
    id: string;
    path: InscriptionPath;
    rank: number;
    description: string;
}
export declare class SkillTreeEngine {
    private nodes;
    constructor();
    private initializeNodes;
    getAvailableNodes(path: InscriptionPath, currentRank: number): SkillNode[];
}
