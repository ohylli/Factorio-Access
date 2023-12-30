--data:
data.raw.character.character.has_belt_immunity = true
local resource_map_node = table.deepcopy(data.raw.container) 
resource_map_node.name = "map-node"
resource_map_node.type = "simple-entity-with-force"
--resource_map_node.inventory_size = 0

resource_map_node.collision_box = {{-0, -0}, {0, 0}}
resource_map_node.collision_mask = {}
resource_map_node.selection_box = nil
resource_map_node.order = "z"
resource_map_node.max_health = 2147483648
resource_map_node.picture = {
	filename = "__FactorioAccess__/Graphics/invisible.png",
	width = 1,
	height = 1,
	direction_count = 1
}

--Changes to Vanilla Objects (Mostly removal of collisions with the player)
local pipe = data.raw.pipe.pipe
pipe.collision_mask = {"object-layer", "floor-layer", "water-tile"}

local pipe_to_ground = data.raw["pipe-to-ground"]["pipe-to-ground"]
pipe_to_ground.collision_mask = {"object-layer", "floor-layer", "water-tile"}

local small_electric_pole = data.raw["electric-pole"]["small-electric-pole"]
small_electric_pole.collision_mask = {"object-layer", "floor-layer", "water-tile"}


local medium_electric_pole = data.raw["electric-pole"]["medium-electric-pole"]
medium_electric_pole.collision_mask = {"object-layer", "floor-layer", "water-tile"}

resource_def={richness = 4}

data.raw["map-gen-presets"].default["faccess-compass-valley"] = {
    order="_A",
    basic_settings={
        autoplace_controls = {
            coal = resource_def,
            ["copper-ore"] = resource_def,
            ["crude-oil"] = resource_def,
            ["iron-ore"] = resource_def,
            stone = resource_def,
            ["uranium-ore"] = resource_def
        },
        seed = 3814061204,
        starting_area = 4,
        peaceful_mode = true,
        cliff_settings = {
            name = "cliff",
            cliff_elevation_0 = 10,
            cliff_elevation_interval = 240,
            richness = 0.1666666716337204
        }
    },
    advanced_settings ={
        enemy_evolution = {
            enabled = true,
            time_factor = 0,
            destroy_factor = 0.006,
            pollution_factor = 1e-07
         },
         enemy_expansion ={
            enabled = false
         }
    }
}

data.raw["map-gen-presets"].default["faccess-peaceful"] = {
    order="_B",
    basic_settings={
        peaceful_mode = true,
    }
}

data.raw["map-gen-presets"].default["faccess-enemies-off"] = {
    order="_B",
    basic_settings={
        autoplace_controls = {
            ["enemy-base"] = {frequency=0} 
        }
    }
}


data:extend({
 resource_map_node,
{
   type = "sound",
   name = "Face-Dir",
   filename = "__FactorioAccess__/Audio/1face_dir.ogg",
   volume = 1,
   preload = true
},
{
   type = "sound",
   name = "Inventory-Move",
   filename = "__FactorioAccess__/Audio/inventory-move.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Mine-Building",
   filename = "__FactorioAccess__/Audio/mine_02.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Open-Inventory-Sound",
   filename = "__core__/sound/gui-green-button.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Close-Inventory-Sound",
   filename = "__core__/sound/gui-green-confirm.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Change-Menu-Tab-Sound",
   filename = "__core__/sound/gui-switch.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Rotate-Hand-Sound",
   filename = "__core__/sound/gui-back.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "train-honk-short",
   filename = "__FactorioAccess__/Audio/train-honk-short-2x-GotLag.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "train-honk-long",
   filename = "__FactorioAccess__/Audio/train-honk-long-freesound.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "damaged-character-shield",
   filename = "__FactorioAccess__/Audio/beep_16-shield-damaged.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "damaged-character-no-shield",
   filename = "__FactorioAccess__/Audio/beep-06-character-damaged.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "damaged-entity-alert",
   filename = "__FactorioAccess__/Audio/alarm-siren-warning-01-structure-damaged.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "teleported",
   filename = "__FactorioAccess__/Audio/alarm-siren-loop-09-teleported.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "aim-locked",
   filename = "__FactorioAccess__/Audio/beep-12-aim-locked.wav", 
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "enemy-presence-high",
   filename = "__FactorioAccess__/Audio/alarm-siren-loop-11-enemy-presence-high.wav",
   volume = 1,
   preload = true
},

{
    type = "custom-input",
    name = "cursor-up",
    key_sequence = "W",
    linked_game_control = "move-up",
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-down",
    key_sequence = "S",
    linked_game_control = "move-down",
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-left",
    key_sequence = "A",
    linked_game_control = "move-left",
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-right",
    key_sequence = "D",
    linked_game_control = "move-right",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-up",
    key_sequence = "CONTROL + SHIFT + W",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-down",
    key_sequence = "CONTROL + SHIFT + S",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-left",
    key_sequence = "CONTROL + SHIFT + A",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-right",
    key_sequence = "CONTROL + SHIFT + D",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-cursor-coords",
    key_sequence = "K",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-cursor-distance-and-direction",
    key_sequence = "SHIFT + K",
    consuming = "none"
},

{
    type = "custom-input",
    name = "return-cursor-to-player",
    key_sequence = "J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "release-cursor",
    key_sequence = "CONTROL + J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "teleport-to-cursor",
    key_sequence = "SHIFT + T",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-cursor",
    key_sequence = "I",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-size-increment",
    key_sequence = "SHIFT + I",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-size-decrement",
    key_sequence = "CONTROL + I",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-inventory-bar-by-1",
    key_sequence = "PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-inventory-bar-by-5",
    key_sequence = "SHIFT + PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-inventory-bar-by-100",
    key_sequence = "CONTROL + PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-inventory-bar-by-1",
    key_sequence = "PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-inventory-bar-by-5",
    key_sequence = "SHIFT + PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-inventory-bar-by-100",
    key_sequence = "CONTROL + PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-train-wait-times-by-5",
    key_sequence = "PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-train-wait-times-by-60",
    key_sequence = "CONTROL + PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-train-wait-times-by-5",
    key_sequence = "PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-train-wait-times-by-60",
    key_sequence = "CONTROL + PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-rail-structure-ahead",
    key_sequence = "J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-rail-structure-behind",
    key_sequence = "SHIFT + J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "rescan",
    key_sequence = "END",
    alternative_key_sequence = "RCTRL",
    consuming = "none"
},

{
    type = "custom-input",
    name = "a-scan-list-main-up-key",
    key_sequence = "PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "a-scan-list-main-down-key",
    key_sequence = "PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-list-up",
    key_sequence = "PAGEUP",
    alternative_key_sequence = "UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-list-down",
    key_sequence = "PAGEDOWN",
    alternative_key_sequence = "DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-list-middle",
    key_sequence = "HOME",
    alternative_key_sequence = "RSHIFT",
    consuming = "none"
},
{
    type = "custom-input",
    name = "jump-to-scan",
    key_sequence = "CONTROL + HOME",
    alternative_key_sequence = "CONTROL + RSHIFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-category-up",
    key_sequence = "CONTROL + PAGEUP",
    alternative_key_sequence = "CONTROL + UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-category-down",
    key_sequence = "CONTROL + PAGEDOWN",
    alternative_key_sequence = "CONTROL + DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-mode-up",
    key_sequence = "SHIFT + N",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-mode-down",
    key_sequence = "N",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-selection-up",
    key_sequence = "SHIFT + PAGEUP",
    alternative_key_sequence = "SHIFT + UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-selection-down",
    key_sequence = "SHIFT + PAGEDOWN",
    alternative_key_sequence = "SHIFT + DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "repeat-last-spoken",
    key_sequence = "CONTROL + TAB",
    consuming = "none"
},

{
    type = "custom-input",
    name = "tile-cycle",
    key_sequence = "SHIFT + F",
    consuming = "none"
},

{
    type = "custom-input",
    name = "pickup-items",
    key_sequence = "F",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-inventory",
    key_sequence = "E",
    consuming = "none"
},

{
    type = "custom-input",
    name = "close-menu",
    key_sequence = "E",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-1",
    key_sequence = "1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-2",
    key_sequence = "2",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-3",
    key_sequence = "3",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-4",
    key_sequence = "4",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-5",
    key_sequence = "5",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-6",
    key_sequence = "6",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-7",
    key_sequence = "7",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-8",
    key_sequence = "8",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-9",
    key_sequence = "9",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-10",
    key_sequence = "0",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-1",
    key_sequence = "CONTROL + 1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-2",
    key_sequence = "CONTROL + 2",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-3",
    key_sequence = "CONTROL + 3",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-4",
    key_sequence = "CONTROL + 4",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-5",
    key_sequence = "CONTROL + 5",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-6",
    key_sequence = "CONTROL + 6",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-7",
    key_sequence = "CONTROL + 7",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-8",
    key_sequence = "CONTROL + 8",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-9",
    key_sequence = "CONTROL + 9",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-10",
    key_sequence = "CONTROL + 0",
    consuming = "none"
},

{
    type = "custom-input",
    name = "switch-menu-or-gun",
    key_sequence = "TAB",
    consuming = "none"
},

{
    type = "custom-input",
    name = "reverse-switch-menu-or-gun",
    key_sequence = "SHIFT + TAB",
    consuming = "none"
},

{
    type = "custom-input",
    name = "mine-access-sounds",
    key_sequence = "X",
    linked_game_control = "mine",
    consuming = "none"
},

{
    type = "custom-input",
    name = "mine-tiles",
    key_sequence = "X",
    linked_game_control = "mine",
    consuming = "none"
},

{
    type = "custom-input",
    name = "mine-area",
    key_sequence = "SHIFT + X",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cut-paste-tool-comment",
    key_sequence = "CONTROL + X",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-menu",
    key_sequence = "LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-hand",
    key_sequence = "LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-entity",
    key_sequence = "LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "repair-area",
    key_sequence = "CONTROL + SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "crafting-all",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "transfer-one-stack",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "equip-item",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-rail-builder",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quick-build-rail-left-turn",
    key_sequence = "CONTROL + LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quick-build-rail-right-turn",
    key_sequence = "CONTROL + RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "transfer-all-stacks",
    key_sequence = "CONTROL + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "free-place-straight-rail",
    key_sequence = "CONTROL + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "transfer-half-of-all-stacks",
    key_sequence = "CONTROL + RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "crafting-5",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "menu-clear-filter",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-entity-status",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "rotate-building",
    key_sequence = "R",
    linked_game_control = "rotate",
    consuming = "game-only"
},

{
    type = "custom-input",
    name = "inventory-read-weapons-data",
    key_sequence = "R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-reload-weapons",
    key_sequence = "SHIFT + R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-remove-all-weapons-and-ammo",
    key_sequence = "CONTROL + SHIFT + R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "item-info",
    key_sequence = "Y",
    consuming = "none"
},

{
    type = "custom-input",
    name = "item-info-last-indexed",
    key_sequence = "SHIFT + Y",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-time-and-research-progress",
    key_sequence = "T",
    consuming = "none"
},

{
    type = "custom-input",
    name = "save-game-manually",
    key_sequence = "F1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-walk",
    key_sequence = "CONTROL + W",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-build-lock",
    key_sequence = "CONTROL + B",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-vanilla-mode",
    key_sequence = "CONTROL + ALT + V",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-cursor-hiding",
    key_sequence = "CONTROL + ALT + C",
    consuming = "none"
},

{
    type = "custom-input",
    name = "clear-renders",
    key_sequence = "CONTROL + ALT + R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "recalibrate-zoom",
    key_sequence = "CONTROL + END",
    alternative_key_sequence = "CONTROL + RCTRL",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-hand",
    key_sequence = "Q",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-hand-from-inventory",
    key_sequence = "CONTROL + Q",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-warnings-menu",
    key_sequence = "P",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-fast-travel-menu",
    key_sequence = "V",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-structure-travel-menu",
    key_sequence = "CONTROL + S",
    consuming = "none"
},

{
    type = "custom-input",
    name = "train-menu-up",
    key_sequence = "UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "train-menu-down",
    key_sequence = "DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "train-menu-left",
    key_sequence = "LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "train-menu-right",
    key_sequence = "RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-north",
    key_sequence = "UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-south",
    key_sequence = "DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-east",
    key_sequence = "RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-west",
    key_sequence = "LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-input-priority-left",
    key_sequence = "SHIFT + LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-input-priority-right",
    key_sequence = "SHIFT + RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-output-priority-left",
    key_sequence = "CONTROL + LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-output-priority-right",
    key_sequence = "CONTROL + RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-filter",
    key_sequence = "CONTROL + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "connect-rail-vehicles",
    key_sequence = "G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "disconnect-rail-vehicles",
    key_sequence = "SHIFT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-read-armor-stats",
    key_sequence = "G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-read-equipment-list",
    key_sequence = "SHIFT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-remove-all-equipment-and-armor",
    key_sequence = "CONTROL + SHIFT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "debug-test-key",
    key_sequence = "ALT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "launch-rocket",
    key_sequence = "SPACE",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-alt-zoom-in",
    key_sequence = "X",
    linked_game_control = "alt-zoom-in",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-alt-zoom-out",
    key_sequence = "X",
    linked_game_control = "alt-zoom-out",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-zoom-out",
    key_sequence = "X",
    linked_game_control = "zoom-out",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-zoom-in",
    key_sequence = "X",
    linked_game_control = "zoom-in",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-debug-reset-zoom-2x",
    key_sequence = "X",
    linked_game_control = "debug-reset-zoom-2x",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-debug-reset-zoom",
    key_sequence = "X",
    linked_game_control = "debug-reset-zoom",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-read",
    key_sequence = "L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-increment",
    key_sequence = "SHIFT + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-decrement",
    key_sequence = "CONTROL + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-toggle-personal-logistics",
    key_sequence = "CONTROL + SHIFT + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "access-config-version1-DO-NOT-EDIT",
    key_sequence = "A",
    consuming = "none"
},

{
    type = "custom-input",
    name = "access-config-version2-DO-NOT-EDIT",
    key_sequence = "A",
    consuming = "none"
}

})

--Additions below for removing tips and tricks
vanilla_tip_and_tricks_item_table=
{
   "introduction",
      "game-interaction",
      "show-info",
      --"e-confirm",
      "clear-cursor",
      "pipette",
      "stack-transfers",
      
      "entity-transfers",
      "z-dropping",
      "shoot-targeting",
      "bulk-crafting",
   
   
   "inserters",
      "burner-inserter-refueling",
      "long-handed-inserters",
      "move-between-labs",
      "insertion-limits",
      "limit-chests",
   
   
   "transport-belts",--in category "belt"
      "belt-lanes",
      "splitters",
      "splitter-filters",
      "underground-belts",
   
   
   "electric-network",
      "steam-power",
      "low-power",
      "electric-pole-connections",
      "connect-switch",
   
   
   "copy-entity-settings",--in category "copy-paste"
      "copy-paste-trains",
      "copy-paste-filters",
      "copy-paste-requester-chest",
      "copy-paste-spidertron",
   
   
   "drag-building",
      "drag-building-poles",
      "pole-dragging-coverage",
      "drag-building-underground-belts",
      "fast-belt-bending",
      "fast-obstacle-traversing",
   
   
   "trains",
      "rail-building",
      "train-stops",
      "rail-signals-basic",
      "rail-signals-advanced",
      "gate-over-rail",
      
      "pump-connection",
      "train-stop-same-name",
   
   
   "logistic-network",
      "personal-logistics",
      "construction-robots",
      "passive-provider-chest",
      "storage-chest",
      "requester-chest",
   
      "active-provider-chest",
      "buffer-chest",
   
   
   "ghost-building",
      "ghost-rail-planner",
      "copy-paste",
   
   
   "fast-replace",
      "fast-replace-direction",
      "fast-replace-belt-splitter",
      "fast-replace-belt-underground",
   
   --no category
      "rotating-assemblers",
      "circuit-network",
   
};

function remove_tip_and_tricks_item(inname)
   data.raw["tips-and-tricks-item"][inname]=nil;
   for _,item in pairs(data.raw["tips-and-tricks-item"]) do
      if(item.dependencies) then
         local backup=table.deepcopy(item.dependencies);
         item.dependencies={"e-confirm"};
         for _,str in pairs(backup) do
            if(str~=inname) then table.insert(item.dependencies,str); end
         end
      end
   end
end

   data.raw["tips-and-tricks-item"]["introduction"].category="game-interaction";
   data.raw["tips-and-tricks-item"]["introduction"].trigger=nil;

   data.raw["tips-and-tricks-item"]["show-info"].starting_status="unlocked";
   data.raw["tips-and-tricks-item"]["show-info"].dependencies=nil;

   data.raw["tips-and-tricks-item"]["e-confirm"].starting_status="unlocked";
   data.raw["tips-and-tricks-item"]["e-confirm"].trigger=nil;
   data.raw["tips-and-tricks-item"]["e-confirm"].skip_trigger={type="use-confirm"};--**nil
   data.raw["tips-and-tricks-item"]["e-confirm"].dependencies=nil;


for _,item in pairs(vanilla_tip_and_tricks_item_table) do
   remove_tip_and_tricks_item(item);
end
--Additions above for removing tips and tricks