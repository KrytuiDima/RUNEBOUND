export interface Point { x: number; y: number; t: number; }
export interface RecognitionResult { match: string; confidence: number; }
export interface SpellConfiguration { id: string; name: string; element: string; baseDamage: number; baseManaCost: number; baseCastTime: number; runeType: string; isClosedForm: boolean; }
export enum InscriptionPath { FLUX = 'FLUX', ETCHER = 'ETCHER', GEOMANCER = 'GEOMANCER' }
export interface PlayerStats { level: number; int: number; stab: number; res: number; path: InscriptionPath; pathRanks: Record<InscriptionPath, number>; }
