import { ShapeDefinition } from '../model/Game';

export class GameConstants {
  static readonly GRID_SIZE = 5;
  static readonly BLOCK_PREVIEW_SIZE = 17;
  static readonly CLEAR_ANIMATION_DELAY_MS = 60;
  static readonly GAMEOVER_FILL_DELAY_MS = 5;
  static readonly ALL_SHAPES: ShapeDefinition[] = [

    // ── O / Square pieces ────────────────────────────────────────────────────
    {
      name: 'O_Square_3x3',
      cells: [
        { row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 },
        { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 1, col: 2 },
        { row: 2, col: 0 }, { row: 2, col: 1 }, { row: 2, col: 2 }
      ],
      color: $r('app.color.shape_color_O')
    },
    {
      name: 'rect_horizontal',
      cells: [
        { row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 },
        { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 1, col: 2 }
      ],
      color: $r('app.color.shape_color_O')
    },
    {
      name: 'rect_vertical',
      cells: [
        { row: 0, col: 0 }, { row: 0, col: 1 },
        { row: 1, col: 0 }, { row: 1, col: 1 },
        { row: 2, col: 0 }, { row: 2, col: 1 }
      ],
      color: $r('app.color.shape_color_O')
    },
    {
      name: 'O_Square_2x2',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 0 }, { row: 1, col: 1 }],
      color: $r('app.color.shape_color_O')
    },

    // ── I pieces ─────────────────────────────────────────────────────────────
    {
      name: 'I_Vertical',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 2, col: 0 }, { row: 3, col: 0 }],
      color: $r('app.color.shape_color_I')
    },
    {
      name: 'I_Horizontal',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 0, col: 3 }],
      color: $r('app.color.shape_color_I')
    },

    // ── L pieces ─────────────────────────────────────────────────────────────
    {
      name: 'L_0',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 2, col: 0 }, { row: 2, col: 1 }],
      color: $r('app.color.shape_color_L')
    },
    {
      name: 'L_90',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 1, col: 2 }],
      color: $r('app.color.shape_color_L')
    },
    {
      name: 'L_180',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 1 }, { row: 2, col: 1 }],
      color: $r('app.color.shape_color_L')
    },
    {
      name: 'L_270',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 1, col: 2 }],
      color: $r('app.color.shape_color_L')
    },
    {
      name: 'L_2_0',
      cells: [
        { row: 0, col: 0 }, { row: 1, col: 0 }, { row: 2, col: 0 }, { row: 2, col: 1 }, { row: 2, col: 2 }
      ],
      color: $r('app.color.shape_color_L')
    },

    // ── J pieces ─────────────────────────────────────────────────────────────
    {
      name: 'J_0',
      cells: [{ row: 0, col: 1 }, { row: 1, col: 1 }, { row: 2, col: 1 }, { row: 2, col: 0 }],
      color: $r('app.color.shape_color_J')
    },
    {
      name: 'J_90',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 1, col: 2 }],
      color: $r('app.color.shape_color_J')
    },
    {
      name: 'J_180',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 0 }, { row: 2, col: 0 }],
      color: $r('app.color.shape_color_J')
    },
    {
      name: 'J_270',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 1, col: 0 }],
      color: $r('app.color.shape_color_J')
    },

    // ── T pieces ─────────────────────────────────────────────────────────────
    {
      name: 'T_0',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 1, col: 1 }],
      color: $r('app.color.shape_color_T')
    },
    {
      name: 'T_90',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 2, col: 0 }],
      color: $r('app.color.shape_color_T')
    },
    {
      name: 'T_180',
      cells: [{ row: 0, col: 1 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 1, col: 2 }],
      color: $r('app.color.shape_color_T')
    },
    {
      name: 'T_270',
      cells: [{ row: 0, col: 1 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 2, col: 1 }],
      color: $r('app.color.shape_color_T')
    },

    // ── S pieces ─────────────────────────────────────────────────────────────
    {
      name: 'S_0',
      cells: [{ row: 0, col: 1 }, { row: 0, col: 2 }, { row: 1, col: 0 }, { row: 1, col: 1 }],
      color: $r('app.color.shape_color_S')
    },
    {
      name: 'S_90',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 2, col: 1 }],
      color: $r('app.color.shape_color_S')
    },

    // ── Z pieces ─────────────────────────────────────────────────────────────
    {
      name: 'Z_0',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 1 }, { row: 1, col: 2 }],
      color: $r('app.color.shape_color_Z')
    },
    {
      name: 'Z_90',
      cells: [{ row: 0, col: 1 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 2, col: 0 }],
      color: $r('app.color.shape_color_Z')
    }

  ];
}
