-- Hyprland Lua config -- converted from hyprland.conf
-- Reference: https://wiki.hypr.land/Configuring/Start/
--            https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

------------------
---- MONITORS ----
------------------

-- monitor=eDP-1,1920x1080@60,0x0,1,vrr,0
hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1,
	vrr = 0,
})

-- monitor=HDMI-A-1,highrr,-1920x0,1
hl.monitor({
	output = "HDMI-A-1",
	mode = "highrr",
	position = "-1920x0",
	scale = 1,
})

-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "-3840x0", scale = 1, vrr = 0 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "kitty -e yazi"
local menu = "wofi --show drun"
local browser = "zen-browser"

local custom_sh = "/home/tomas/.local/bin"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- hl.exec_cmd("waybar") -- replaced by the quickshell bar (~/.config/quickshell)
	hl.exec_cmd("hypridle")
	hl.exec_cmd("qs") -- quickshell popups (~/.config/quickshell)
	-- hl.exec_cmd("hyprpaper")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 1,

		border_size = 1,

		col = {
			active_border = "rgba(98f329ff)",
			inactive_border = "rgba(101010aa)",
		},

		resize_on_border = true,
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 1,

		active_opacity = 1,
		inactive_opacity = 1,

		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		background_color = 0xff151515,
		disable_splash_rendering = true,
		allow_session_lock_restore = true,
	},
})

-- Animation curves / animations (kept from the .conf; take effect if animations.enabled = true)
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "pt",
		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},

	cursor = {
		no_hardware_cursors = true,
	},
})

-- gesture = 3, horizontal, workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(menu))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + K", hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + L", hl.dsp.workspace.swap_monitors({ monitor1 = "eDP-1", monitor2 = "HDMI-A-1" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- [Custom] Execute custom programs
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("wlogout -b 1 -r 10 -R 20"))
hl.bind("Print", hl.dsp.exec_cmd(custom_sh .. "/screenshot-area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(custom_sh .. "/screenshot-all"))

-- [Custom] Move focused window around
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces (mainMod + 0-9) / move active window to workspace (mainMod + SHIFT + 0-9)
for i = 1, 10 do
	local key = i % 10 -- 10 -> key "0"
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- [Custom] Previous / next workspace on the focused monitor, like the 3-finger swipe:
-- leftmost + left = stay, rightmost + right = new workspace (unless it's already empty)
local function workspace_step(dir)
	return function()
		local cur = hl.get_active_workspace()
		if not cur or not cur.monitor then
			return
		end
		local ids = {}
		for _, w in ipairs(hl.get_workspaces()) do
			if not w.special and w.id and w.id > 0 and w.monitor and w.monitor.id == cur.monitor.id then
				table.insert(ids, w.id)
			end
		end
		table.sort(ids)
		local i = 1
		for k, id in ipairs(ids) do
			if id == cur.id then
				i = k
			end
		end
		if dir < 0 then
			if i > 1 then
				hl.dispatch(hl.dsp.focus({ workspace = ids[i - 1] }))
			end
		elseif i < #ids then
			hl.dispatch(hl.dsp.focus({ workspace = ids[i + 1] }))
		elseif cur.windows > 0 then
			hl.dispatch(hl.dsp.focus({ workspace = "emptynm" }))
		end
	end
end
hl.bind(mainMod .. " + CTRL + left", workspace_step(-1))
hl.bind(mainMod .. " + CTRL + right", workspace_step(1))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore maximize requests from apps.
hl.window_rule({
	name = "suppress-maximize",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Float + place Bluetooth Manager
hl.window_rule({
	name = "float-blueman-manager",
	match = { class = "^(blueman-manager)$" },
	float = true,
	size = { 90, 500 },
	move = { "monitor_w-320", "35" },
})

-- Float + place Network Manager
hl.window_rule({
	name = "float-nm-connection-editor",
	match = { class = "^(nm-connection-editor)$" },
	float = true,
	size = { 110, 400 },
	move = { "monitor_w-220", "35" },
})

-- Float Pavucontrol
hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	float = true,
	size = { 1000, 700 },
})

-- Float misc Tk dialogs
hl.window_rule({
	name = "float-tk",
	match = { class = "^(Tk)$" },
	float = true,
})
