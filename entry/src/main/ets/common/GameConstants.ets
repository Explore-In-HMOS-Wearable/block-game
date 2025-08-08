import { ShapeDefinition } from '../model/Game';

export class GameConstants {
  static readonly GRID_SIZE = 5;
  static readonly BLOCK_PREVIEW_SIZE = 15;
  static readonly CLEAR_ANIMATION_DELAY_MS = 60;
  static readonly GAMEOVER_FILL_DELAY_MS = 5;
  static readonly ALL_SHAPES: ShapeDefinition[] = [
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
      name: 'I_Vertical',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 2, col: 0 }, { row: 3, col: 0 }],
      color: $r('app.color.shape_color_I')
    },
    {
      name: 'I_Horizontal',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 0, col: 3 }],
      color: $r('app.color.shape_color_I')
    },

    {
      name: 'O_Square_2x2',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 0 }, { row: 1, col: 1 }],
      color: $r('app.color.shape_color_O')
    },

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
      name: 'J_0',
      cells: [{ row: 0, col: 1 }, { row: 1, col: 1 }, { row: 2, col: 1 }, { row: 2, col: 0 }],
      color: $r('app.color.shape_color_I')
    },
    {
      name: 'J_90',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 1, col: 1 }, { row: 1, col: 2 }],
      color: $r('app.color.shape_color_I')
    },
    {
      name: 'J_180',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 0 }, { row: 2, col: 0 }],
      color: $r('app.color.shape_color_I')
    },
    {
      name: 'J_270',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 0, col: 2 }, { row: 1, col: 0 }],
      color: $r('app.color.shape_color_I')
    },
    {
      name: 'L_2_0',
      cells: [
        { row: 0, col: 0 }, { row: 1, col: 0 }, { row: 2, col: 0 }, { row: 2, col: 1 }, { row: 2, col: 2 }
      ],
      color: $r('app.color.shape_color_L')
    }


  ];
}