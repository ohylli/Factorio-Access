
--Returns the localised name of an object as a string
function get_translated_name_string(object,pindex)--*** todo make this work
   if  players[pindex].localisations == nil then
       players[pindex].localisations = {}
   end
   local size = 0
   for _ in pairs(players[pindex].localisations) do size = size + 1 end
   --game.print(size .. " localisations saved ",{volume_modifier=0})
   
   local result = players[pindex].localisations[object.localised_name]
   --game.print(object.localised_name)
   --game.print("table ^ ")
   
   if result ~= nil and result ~= "" then
      --game.print("succes")
      return result
   else
      --game.print("fallback used")
      return object.name
   end
end

--Localisation test with inventory items
function localise_inventory_item_names(pindex)
   if  players[pindex].loc_inputs == nil then
       players[pindex].loc_inputs = {}
   end

   local inv = game.get_player(pindex).get_main_inventory()
   for i = 1, #inv, 1 do 
      local stack = inv[i]
      if stack and stack.valid_for_read then
         game.get_player(pindex).request_translation(stack.prototype.localised_name)
      end
   end
end

--Populates the appropriate localised string arrays for every translation
function translated_string_handler(event)
   local pindex = event.player_index
   local successful = event.translated
   local loc_table = event.localised_string
   local result_string = event.result
   
   if not successful then
      game.print("translation request failed",{volume_modifier=0})
      return
   end
   
   if  players[pindex].localisations == nil then
       players[pindex].localisations = {}
   end
   
   players[pindex].localisations[loc_table] = result_string
   game.print("translated: " .. players[pindex].localisations[loc_table],{volume_modifier=0})--These all work
   --game.print(loc_table)
   --game.print("above from event")
end