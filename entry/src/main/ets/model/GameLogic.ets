/**
 * GameLogic.ets - Pure game logic module
 *
 * Design rules:
 *  - No ArkUI component imports, no AppStorage, no timers, no $r().
 *  - Grid cells are typed as (object | null). null = empty; any non-null = occupied.
 *    In production code the non-null value will be a Resource (color).
 *    In unit tests any plain object {} is a valid occupied marker.
 *  - All functions are pure: they never mutate their input, always return new objects.
 *  - RNG is deterministic: seed is passed explicitly so tests can be reproducible.
 */

import { Cell, PlacementInfo } from './Game';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/** null = empty cell, non-null object = occupied (holds a color Resource in production) */
export type CellValue = Resource | object | null;

/** 2-D grid of cell values. Row-major: grid[row][col]. */
export type GridState = CellValue[][];

/** A minimal shape descriptor used by functions that need only cell geometry. */
export interface ShapeLayout {
  name: string;
  cells: Cell[];
}

export interface RngResult {
  seed: number;
  value: number; // always in [0, 1)
}

export interface ShapeIndexResult {
  seed: number;
  index: number;
}

export interface CompletedLinesResult {
  cellsToClear: Cell[];
  clearedRows: number[];
  clearedCols: number[];
}

// ---------------------------------------------------------------------------
// Grid utilities
// ---------------------------------------------------------------------------

/**
 * Creates a new empty grid of the given size.
 * All cells are null.
 */
export function createEmptyGrid(size: number): GridState {
  const grid: GridState = [];
  for (let r = 0; r < size; r++) {
    const row: CellValue[] = [];
    for (let c = 0; c < size; c++) {
      row.push(null);
    }
    grid.push(row);
  }
  return grid;
}

/**
 * Returns a deep copy of the grid.
 * Prevents accidental mutation of the source state.
 */
export function cloneGrid(grid: GridState): GridState {
  return grid.map(row => [...row]);
}

// ---------------------------------------------------------------------------
// RNG
// ---------------------------------------------------------------------------

/**
 * Advances the LCG seed by one step and returns the new seed and a float in [0, 1).
 * Divisor is 0x100000000 so value is strictly less than 1.0.
 */
export function nextRand(seed: number): RngResult {
  const nextSeed = (1664525 * seed + 1013904223) >>> 0;
  return {
    seed: nextSeed,
    value: nextSeed / 0x100000000
  };
}

/**
 * Returns a shape index in [0, shapeCount) using the given seed.
 * Throws if shapeCount <= 0.
 */
export function randomShapeIndex(seed: number, shapeCount: number): ShapeIndexResult {
  if (shapeCount <= 0) {
    throw new Error(`randomShapeIndex: shapeCount must be > 0, got ${shapeCount}`);
  }
  const rng = nextRand(seed);
  return {
    seed: rng.seed,
    index: Math.floor(rng.value * shapeCount)
  };
}

// ---------------------------------------------------------------------------
// Placement
// ---------------------------------------------------------------------------

/**
 * Checks whether a shape can be placed with its top-left cell at (anchorRow, anchorCol).
 * Returns canPlace=false if any target cell is out of bounds or already occupied.
 * Does NOT mutate the grid.
 */
export function canPlaceShape(
  grid: GridState,
  shapeCells: Cell[],
  anchorRow: number,
  anchorCol: number
): PlacementInfo {
  const size = grid.length;
  const targetCells: Cell[] = [];
  let canPlace = true;

  for (const shapeCell of shapeCells) {
    const targetRow = anchorRow + shapeCell.row;
    const targetCol = anchorCol + shapeCell.col;
    if (
      targetRow < 0 ||
      targetRow >= size ||
      targetCol < 0 ||
      targetCol >= size ||
      grid[targetRow][targetCol] !== null
    ) {
      canPlace = false;
      break;
    }
    targetCells.push({ row: targetRow, col: targetCol });
  }
  return { targetCells, canPlace };
}

/**
 * Returns a new grid with the given cells filled with color.
 * The original grid is never modified.
 */
export function applyShapeToGrid(
  grid: GridState,
  targetCells: Cell[],
  color: CellValue
): GridState {
  const newGrid = cloneGrid(grid);
  for (const cell of targetCells) {
    newGrid[cell.row][cell.col] = color;
  }
  return newGrid;
}

/**
 * Returns true if the shape can be placed in at least one valid position.
 * Iterates all (row, col) anchor positions within the grid.
 */
export function canShapeBePlacedAnywhere(
  grid: GridState,
  shapeCells: Cell[],
  gridSize: number
): boolean {
  for (let row = 0; row < gridSize; row++) {
    for (let col = 0; col < gridSize; col++) {
      if (canPlaceShape(grid, shapeCells, row, col).canPlace) {
        return true;
      }
    }
  }
  return false;
}

// ---------------------------------------------------------------------------
// Line clearing
// ---------------------------------------------------------------------------

/**
 * Inspects rows and columns touched by the placed cells.
 * A line (row or column) is complete when every cell in it is non-null.
 * Returns the set of cells to clear (no duplicates at row/column intersections),
 * plus the indices of cleared rows and columns for score/animation purposes.
 */
export function getCompletedLines(
  grid: GridState,
  placedCells: Cell[]
): CompletedLinesResult {
  const size = grid.length;
  const rowsToCheck = new Set(placedCells.map(c => c.row));
  const colsToCheck = new Set(placedCells.map(c => c.col));
  const cellsToClear: Cell[] = [];
  const clearedRows: number[] = [];
  const clearedCols: number[] = [];

  rowsToCheck.forEach(rowIndex => {
    if (grid[rowIndex].every(cell => cell !== null)) {
      clearedRows.push(rowIndex);
      for (let j = 0; j < size; j++) {
        cellsToClear.push({ row: rowIndex, col: j });
      }
    }
  });

  colsToCheck.forEach(colIndex => {
    let isColFull = true;
    for (let i = 0; i < size; i++) {
      if (grid[i][colIndex] === null) {
        isColFull = false;
        break;
      }
    }
    if (isColFull) {
      clearedCols.push(colIndex);
      for (let i = 0; i < size; i++) {
        // Avoid duplicating cells already added by a cleared row
        if (!cellsToClear.some(c => c.row === i && c.col === colIndex)) {
          cellsToClear.push({ row: i, col: colIndex });
        }
      }
    }
  });

  return { cellsToClear, clearedRows, clearedCols };
}

/**
 * Returns a new grid with the specified cells set to null.
 * The original grid is never modified.
 */
export function clearCells(grid: GridState, cellsToClear: Cell[]): GridState {
  const newGrid = cloneGrid(grid);
  for (const cell of cellsToClear) {
    newGrid[cell.row][cell.col] = null;
  }
  return newGrid;
}

// ---------------------------------------------------------------------------
// Scoring
// ---------------------------------------------------------------------------

/**
 * Calculates the score delta for one move.
 *   +10  for placing a shape (always)
 *   +10  per unique cell cleared
 *
 * clearedCellCount must be the deduplicated cell count returned
 * by getCompletedLines().cellsToClear.length.
 */
export function calculateScoreDelta(clearedCellCount: number): number {
  return 10 + clearedCellCount * 10;
}

// ---------------------------------------------------------------------------
// Shape validation
// ---------------------------------------------------------------------------

/**
 * Returns a list of human-readable descriptions of pairs of shapes
 * that have identical cell layouts (order-insensitive).
 * An empty result means all shapes are unique.
 */
export function findDuplicateLayouts(shapes: ShapeLayout[]): string[] {
  const duplicates: string[] = [];

  const serialize = (cells: Cell[]): string =>
    [...cells]
      .sort((a, b) => a.row !== b.row ? a.row - b.row : a.col - b.col)
      .map(c => `${c.row},${c.col}`)
      .join('|');

  for (let i = 0; i < shapes.length; i++) {
    for (let j = i + 1; j < shapes.length; j++) {
      if (
        shapes[i].cells.length === shapes[j].cells.length &&
        serialize(shapes[i].cells) === serialize(shapes[j].cells)
      ) {
        duplicates.push(`${shapes[i].name} == ${shapes[j].name}`);
      }
    }
  }
  return duplicates;
}
