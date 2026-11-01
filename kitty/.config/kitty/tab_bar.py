from kitty.fast_data_types import get_options
from kitty.tab_bar import as_rgb
from kitty.utils import color_as_int

opts = get_options()

CAP_L = ""
CAP_R = ""
ZOOM = "(󰛭) "


def _c(color):
    return as_rgb(color_as_int(color))


def draw_tab(
    draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
):
    bar_bg = _c(draw_data.default_bg)  # tab bar bg, falls back to terminal bg
    chip_text = _c(opts.background)

    if tab.is_active:
        pill = _c(opts.active_tab_background)
        text = _c(opts.active_tab_foreground)
        chip = _c(opts.active_border_color)
    else:
        pill = _c(opts.inactive_tab_background)
        text = _c(opts.inactive_tab_foreground)
        chip = _c(opts.inactive_border_color)

    title = tab.title
    if tab.layout_name == "stack":
        title = ZOOM + title
    limit = max(10, max_title_length - 8)
    if len(title) > limit:
        title = title[: limit - 1] + "…"

    cur = screen.cursor
    cur.bold = cur.italic = False

    if index == 1:
        cur.bg = bar_bg
        screen.draw(" ")

    cur.bg = bar_bg
    cur.fg = pill
    screen.draw(CAP_L)

    cur.bg = pill
    cur.fg = text
    cur.italic = tab.is_active
    screen.draw(title)
    cur.italic = False

    cur.fg = pill
    screen.draw("█")

    cur.bg = chip
    cur.fg = chip_text
    screen.draw(f" {index}")

    cur.bg = bar_bg
    cur.fg = chip
    screen.draw(CAP_R)

    cur.bg = bar_bg
    screen.draw(" ")

    return screen.cursor.x
