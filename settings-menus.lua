--Here: Functions relating to mod settings menus
--Does not include event handlers directly, but can have functions called by them.

function fa_settings_menu_open(pindex)
   --Load menu data
   local settings_menu = players[pindex].fa_settings_menu
   if settings_menu == nil then
      settings_menu = {
         submenu = "",
         index = 0
      }
      players[pindex].fa_settings_menu = settings_menu
   end

   --Set the player menu tracker to this menu
   players[pindex].menu = "fa_settings_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Reset the menu line index to 0
   players[pindex].fa_settings_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   fa_settings_menu(pindex, players[pindex].fa_settings_menu.index, false)
end

--[[
   Settings top menu
   0. About this menu and instructions
   1. Mod controls list (read only) [All controls are listed directly in game]
   2. Mod preferences [Mod settings that affect presentation but have minimal gameplay changes, e.g. chest row length]
   3. Advanced mod settings [Settings that can significantly impact gameplay]
   4. Vanilla preferences [API-accessible preferences that match those found in the vanilla menus, if any ]
]]
function fa_settings_menu(pindex, menu_index, clicked)--****WIP
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod settings menu "
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --Mod controls list (read only) [All controls are listed directly in game]
      if not clicked then
         printout("Mod controls list (read only)", pindex)
      else
         --***
      end
   elseif index == 2 then
      -- Mod preferences [Mod settings that affect presentation but have minimal gameplay changes, e.g. chest row length]
      if not clicked then
         printout("Mod preferences", pindex)
      else
         --***
      end
   elseif index == 3 then
      -- Advanced mod settings [Settings that can significantly impact gameplay]
      if not clicked then
         printout("Advanced mod settings", pindex)
      else
         --***
      end
   end
end
SETTINGS_TOP_MENU_LENGTH = 3

function fa_mod_controls_menu_open(pindex)
   --Load menu data
   local menu_data = players[pindex].fa_mod_controls_menu
   if menu_data == nil then
      menu_data = {
      index = 0,
      load_mod_controls_list(pindex)
      }
      players[pindex].fa_mod_controls_menu = menu_data
   end

   --Set the player menu tracker to this menu
   players[pindex].menu = "fa_mod_controls_menu"
   players[pindex].in_menu = true
   
   --Reset the menu line index to 0
   players[pindex].fa_mod_controls_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   fa_mod_controls_menu(pindex, players[pindex].fa_mod_controls_menu.index, false)
end

function load_mod_controls_list(pindex)--****todo, like loading tutorial strings for the help system

end

--[[
   Mod controls menu
   0. About this menu and instructions
   X. Controls, grouped by chapters, same concept as tutorial steps!
]]
function fa_mod_controls_menu(pindex, menu_index, clicked, pg_up, pg_down)
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod controls menu, with a read-only list of mod controls ".. get_network_name(port)
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   else
      --...read the appropriate localized string 
   end
end
MOD_CONTROLS_MENU_LENGTH = 2

function fa_mod_preferences_menu_open(pindex)
   --Load menu data
   local menu_data = players[pindex].fa_mod_preferences_menu
   if menu_data == nil then
      menu_data = {
      index = 0
      }
      players[pindex].fa_mod_preferences_menu = menu_data
   end

   --Set the player menu tracker to this menu
   players[pindex].menu = "fa_mod_preferences_menu"
   players[pindex].in_menu = true
   
   --Reset the menu line index to 0
   players[pindex].fa_mod_preferences_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   fa_mod_preferences_menu(pindex, players[pindex].fa_mod_preferences_menu.index, false)
end

--[[
   Mod preferences menu
   0. About this menu and instructions
   1. Pref 1
   2. Pref 2
   3. Etc.
]]
function fa_mod_preferences_menu(pindex, menu_index, clicked, pg_up, pg_down)
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod preferences menu, with settings that affect interface but have minimal gameplay changes "
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --...
      if not clicked then
         printout("Mute enemy proximity alerts", pindex)
      else
         --****
      end
   elseif index == 2 then
      --...
      if not clicked then
         printout("Player inventory wrap around", pindex)
      else
         --****
      end
   elseif index == 3 then
      --...
      if not clicked then
         printout("Building inventory wrap around", pindex)
      else
         --****
      end
   elseif index == 4 then
      --...
      if not clicked then
         printout("Building row length", pindex)
      else
         --****
      end
   end
end
MOD_PREFERENCES_MENU_LENGTH = 4


--[[
   Mod advanced settings menu
   0. About this menu and instructions
   1. Pref 1
   2. Pref 2
   3. Etc.
]]
function fa_mod_advanced_settings_menu(pindex, menu_index, clicked, pg_up, pg_down)
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod advanced settings menu, with settings that strongly affect gameplay "
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --...
      if not clicked then
         printout("Triple player reach", pindex)
      else
         --****
      end
   elseif index == 2 then
      --...
      if not clicked then
         printout("Peaceful mode", pindex)
      else
         --****
      end
   elseif index == 3 then
      --...
      if not clicked then
         printout("  ", pindex)
      else
         --****
      end
   end
end
MOD_ADVANCED_SETTINGS_MENU_LENGTH = 2

