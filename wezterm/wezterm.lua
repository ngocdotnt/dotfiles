-- By https://github.com/theopn/dotfiles/blob/main/wezterm/wezterm.lua
-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- Thiw will hold the configuration.
local config = {}
-- local keys = {}
local mouse_bindings = {}

-- Use config builder object if possible
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- launch_menu (Nik Govorov) ===================================================
local launch_menu = {}
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    table.insert(launch_menu, {
        label = "PowerShell",
        args = { "pwsh.exe", "-NoLogo" },
    })
    table.insert(launch_menu, {
        label = "GitBash",
        args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" },
    })
    table.insert(launch_menu, {
        label = "MSYS UCRT64",
        args = { "cmd.exe ", "/k", "C:\\msys64\\msys2_shell.cmd -defterm -here -no-start -ucrt64 -shell bash" },
    })
end
config.launch_menu = launch_menu

-- wezterm configs =============================================================
-- Set Pwsh as the default on Windows
-- config.default_prog = { "pwsh.exe", "-nol" }
config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" }
-- config.default_prog = { "C:\\msys64\\msys2_shell.cdm", "-defterm", "-here", "-no-start", "-ucrt64" "-shell", "bash" }

-- config.front_end = "WebGpu"
config.font = wezterm.font_with_fallback({
    "JetBrainsMonoNL NFM",
    "Hack Nerd Font",
    "MesloLGL Nerd Font",
    { family = "Cambria Math", scale = 1.0 },
})

config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.8
config.font_size = 10
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 250
config.mouse_bindings = mouse_bindings
config.window_close_confirmation = "NeverPrompt"

-- Window setting
-- config.window_decorations = "TITLE|RESIZE"
config.window_decorations = "NONE"
config.win32_system_backdrop = "Auto"
config.max_fps = 144
config.animation_fps = 60
-- config.initial_cols = 280
-- config.initial_rows = 55

config.scrollback_lines = 3000
config.default_workspace = "main"

-- Dim inactive panes
config.inactive_pane_hsb = {
    saturation = 0.24,
    brightness = 0.5,
}

-- Tab Bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.show_tab_index_in_tab_bar = true
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

-- Colors
config.colors = require("cyberdream")
config.force_reverse_video_cursor = true

config.colors.tab_bar = {
    -- background = transparent_bg,
    new_tab = { fg_color = config.colors.background, bg_color = config.colors.brights[6] },
    new_tab_hover = { fg_color = config.colors.background, bg_color = config.colors.foreground },
}

-- Keys
config.leader = { key = " ", mods = "CTRL", timeout_milliseconds = 3000 }
config.keys = {
    -- Send C-a when pressing C-a twice
    -- { key = ";", mods = "LEADER|CTRL", action = act.SendKey({ key = ";", mods = "CTRL" }) },
    { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "phys:Space", mods = "LEADER", action = act.ActivateCommandPalette },

    -- Pane keybindings
    { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
    -- We can make separate keybindings for resizing panes
    -- But Wezterm offers custom "mode" in the name of "KeyTable"
    {
        key = "r",
        mods = "LEADER",
        action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
    },

    -- Tab keybindings
    { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "n", mods = "LEADER", action = act.ShowTabNavigator },
    {
        key = "e",
        mods = "LEADER",
        action = act.PromptInputLine({
            description = wezterm.format({
                { Attribute = { Intensity = "Bold" } },
                { Foreground = { AnsiColor = "Fuchsia" } },
                { Text = "Renaming Tab Title...:" },
            }),
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
    },
    -- Key table for moving tabs around
    { key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
    -- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
    { key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
    { key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

    -- Lastly, workspace
    { key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
}

-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1),
    })
end

config.key_tables = {
    resize_pane = {
        { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
        { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
        { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
        { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
        { key = "Escape", action = "PopKeyTable" },
        { key = "Enter", action = "PopKeyTable" },
    },
    move_tab = {
        { key = "h", action = act.MoveTabRelative(-1) },
        { key = "j", action = act.MoveTabRelative(-1) },
        { key = "k", action = act.MoveTabRelative(1) },
        { key = "l", action = act.MoveTabRelative(1) },
        { key = "Escape", action = "PopKeyTable" },
        { key = "Enter", action = "PopKeyTable" },
    },
}

-- window event =============================================================
wezterm.on("format-tab-title", function(tab, _, _, _, hover)
    local background = config.colors.brights[1]
    local foreground = config.colors.foreground

    if tab.is_active then
        background = config.colors.brights[7]
        foreground = config.colors.background
    elseif hover then
        background = config.colors.brights[8]
        foreground = config.colors.background
    end

    local title = tostring(tab.tab_index + 1)
    return {
        { Foreground = { Color = background } },
        { Text = "█" },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
        { Foreground = { Color = background } },
        { Text = "█" },
    }
end)

wezterm.on("update-status", function(window, pane)
    -- Workspace name
    local stat = window:active_workspace()
    local stat_color = "#f7768e"
    -- It's a little silly to have workspace name all the 10:28
    -- Utilize this to display LDR or current key table name
    if window:active_key_table() then
        stat = window:active_key_table()
        stat_color = "#7dcfff"
    end
    if window:leader_is_active() then
        stat = "LDR"
        stat_color = "#bb9af7"
    end

    local basename = function(s)
        -- Nothing a little regex can't fix
        return string.gsub(s, "(.*[/\\])(.*)", "%2")
    end

    -- Current working directory
    local cwd = pane:get_current_working_dir()
    if cwd then
        if type(cwd) == "userdata" then
            cwd = basename(cwd.file_path)
        else
            cwd = basename(cwd)
        end
    else
        cwd = ""
    end

    -- current command
    local cmd = pane:get_foreground_process_name()
    cmd = cmd and basename(cmd) or ""

    -- Time
    local time = wezterm.strftime("%H:%M")

    -- window size & position
    -- window:set_position(35, 120)
    -- window:set_inner_size(1366, 768)

    -- Left status (left of the tab line)
    window:set_left_status(wezterm.format({
        { Foreground = { Color = stat_color } },
        { Text = "  " },
        { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
        { Text = " |" },
    }))

    -- Right status
    window:set_right_status(wezterm.format({
        -- Wezterm has a built-in nerd fonts
        { Text = wezterm.nerdfonts.md_folder .. " " .. cwd },
        { Text = " | " },
        { Foreground = { Color = "#e0af68" } },
        { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
        "ResetAttributes",
        { Text = " | " },
        { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
        { Text = "  " },
    }))
end)

wezterm.on("gui-startup", function(cmd) -- NOTE if use glazeWM set ignore rule for wezterm
    local screen = wezterm.gui.screens().main
    local ratio = 0.95
    local width, height = 30 + screen.width * ratio, screen.height * ratio
    local tab, pane, window = mux.spawn_window(cmd or {
        position = { x = (screen.width - width) / 2, y = (screen.height - height) / 2 + 15 },
    })
    -- window:gui_window():maximize()
    window:gui_window():set_inner_size(width, height)
end)

-- mouse bindings ==============================================================
mouse_bindings = {
    {
        event = { Down = { streak = 3, button = "Left" } },
        action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
        mods = "NONE",
    },
}

return config
