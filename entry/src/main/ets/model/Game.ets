export interface Cell {
  row: number,
  col: number
}

export interface ShapeDefinition {
  name: string;
  cells: Cell[];
  color: Resource;
}

export interface PlacementInfo {
  targetCells: Cell[],
  canPlace: boolean
}