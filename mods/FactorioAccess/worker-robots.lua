--Here: Functions relating worker robots, roboports, logistic systems, blueprints
--Does not include event handlers

dirs = defines.direction
MAX_STACK_COUNT = 10

--https://lua-api.factorio.com/latest/classes/LuaLogisticCell.html
--defines.inventory.character_trash

--Increments: 0, 1, half-stack, 1 stack, n stacks
function increment_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in
   
   if amount_min == nil or amount_min == 0 then
      amount_min = 1
   elseif amount_min == 1 then
      amount_min = math.floor(stack_size/2)
   elseif amount_min <= math.floor(stack_size/2) then
      amount_min = stack_size
   elseif amount_min <= stack_size then
      amount_min = amount_min + stack_size
   elseif amount_min > stack_size then
      amount_min = amount_min + stack_size
   end
   
   return amount_min
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function decrement_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in
   
   if amount_min == nil or amount_min == 0 then
      amount_min = nil
   elseif amount_min == 1 then
      amount_min = nil
   elseif amount_min <= math.floor(stack_size/2) then
      amount_min = 1
   elseif amount_min <= stack_size then
      amount_min = math.floor(stack_size/2)
   elseif amount_min > stack_size then
      amount_min = amount_min - stack_size
   end
   
   return amount_min
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function increment_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in
   if amount_max >= stack_size * MAX_STACK_COUNT then
      amount_max = nil
   elseif amount_max > stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max >= stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max >= math.floor(stack_size/2) then
      amount_max = stack_size
   elseif amount_max >= 1 then
      amount_max = math.floor(stack_size/2)
   elseif amount_max == nil or amount_max == 0 then
      amount_max = stack_size
   end
   
   return amount_max
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function decrement_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in
   
   if amount_max > stack_size * MAX_STACK_COUNT then
      amount_max = stack_size * MAX_STACK_COUNT 
   elseif amount_max > stack_size then
      amount_max = amount_max - stack_size
   elseif amount_max >= stack_size then
      amount_max = math.floor(stack_size/2)
   elseif amount_max >= math.floor(stack_size/2) then
      amount_max = 1
   elseif amount_max >= 1 then
      amount_max = 1
   elseif amount_max == nil or amount_max == 0 then
      amount_max = stack_size
   end
   
   return amount_max
end

function logistics_request_toggle_personal_logistics(pindex)
   local p = game.get_player(pindex)
   p.character_personal_logistic_requests_enabled = not p.character_personal_logistic_requests_enabled
   if p.character_personal_logistic_requests_enabled then
      printout("Resumed personal logistics requests",pindex)
   else
      printout("Paused personal logistics requests",pindex)
   end   
end

--Checks if the request for the given item is fulfilled. You can pass the personal logistics request slot index if you have it already
function is_this_player_logistic_request_fulfilled(item_stack,pindex,slot_index_in)
   local result = false
   local slot_index = slot_index_in or nil
   --todo ***
   return result
end

--Returns info string on the current logistics network, or the nearest one, for the current position
function logistics_networks_info(ent,pos_in)
   local result = ""
   local result_code = -1
   local network = nil
   local pos = pos_in
   if pos_in == nil then
      pos = ent.position
   end
   --Check if in range of a logistic network 
   network = ent.surface.find_logistic_network_by_position(pos, ent.force)
   if network ~= nil and network.valid then
      result_code = 1
      result = "Logistics connected to a network with " .. (network.all_logistic_robots + network.all_construction_robots) .. " robots"
   else
      --If not, report nearest logistic network
      network = ent.surface.find_closest_logistic_network_by_position(pos, ent.force)
      if network ~= nil and network.valid then
         result_code = 2
         local pos_n = network.find_cell_closest_to(pos).owner.position
         result = "No logistics connected, nearest network is " .. util.distance(pos,pos_n) .. " tiles " .. direction_lookup(get_direction_of_that_from_this(pos_n,pos))
      else
         result_code = 3
         result = "No logistics connected, no logistic networks nearby, "
      end
   end
   return result, result_code
end

--Finds or assigns the logistic request slot for the item
function get_personal_logistic_slot_index(item_stack,pindex)
   local p = game.get_player(pindex)
   local slots_nil_counter = 0
   local slot_found = false
   local current_slot = nil
   local correct_slot_id = nil
   local slot_id = 0
   
   --Find the correct request slot for this item, if any
   while not slot_found and slots_nil_counter < 250 do
      slot_id = slot_id + 1
      current_slot = p.get_personal_logistic_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         slots_nil_counter = slots_nil_counter + 1
      elseif current_slot.name == item_stack.name then
         slot_found = true
         correct_slot_id = slot_id
      else
         --do nothing
      end
   end
   
   --If needed, find the first empty slot and set it as the correct one
   if not slot_found then
      slot_id = 0
      while not slot_found and slot_id < 250 do
         slot_id = slot_id + 1
         current_slot = p.get_personal_logistic_slot(slot_id)
         if current_slot == nil or current_slot.name == nil then
            slot_found = true
            correct_slot_id = slot_id
         else
            --do nothing
         end
      end
   end
   
   --If no correct or empty slots found then return with error (all slots full)
   if not slot_found then
      return -1
   end
   
   return correct_slot_id
end

function count_active_personal_logistic_slots(pindex) --***laterdo count fulfilled ones in the same loop
   local p = game.get_player(pindex)
   local slots_nil_counter = 0
   local slots_found = 0
   local current_slot = nil
   local slot_id = 0
   
   --Find the correct request slot for this item, if any
   while slots_nil_counter < 250 do
      slot_id = slot_id + 1
      current_slot = p.get_personal_logistic_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         slots_nil_counter = slots_nil_counter + 1
      else 
         slot_founds = slots_found + 1
      end
   end
   
   return slots_found
end

function logistics_info_key_handler(pindex)
   if players[pindex].in_menu == false or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_read(stack,pindex,true)
      elseif players[pindex].menu == "inventory" and stack_inv and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_read(stack_inv,pindex,true)
      else
         --Logistic chest in front
         local ent = get_selected_ent(pindex)
         if can_make_logistic_requests(ent) then
            read_chest_requests_summary(ent,pindex)
            return
         elseif can_set_logistic_filter(ent) then
            local filter = ent.storage_filter
            local result = "Nothing"
            if filter ~= nil then
               result = filter.name
            end
            printout(result .. " set as logistic storage filter",pindex)
            return
         end
         --Empty hand and empty inventory slot
         local result = player_logistic_requests_summary_info(pindex)
         printout(result,pindex)
      end
   elseif players[pindex].menu == "building" and can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_read(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_read(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         read_chest_requests_summary(chest,pindex)
      end
   elseif players[pindex].menu == "building" and can_set_logistic_filter(game.get_player(pindex).opened) then
      local filter = game.get_player(pindex).opened.storage_filter
      local result = "Nothing"
      if filter ~= nil then
         result = filter.name
      end
      printout(result .. " set as logistic storage filter",pindex)
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building",pindex)
   else
      printout("No logistics summary available in this menu",pindex)
   end
end

function logistics_request_increment_min_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_increment_min(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_increment_min(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_increment_min(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_increment_min(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions",pindex)
      end
   elseif players[pindex].menu == "building" and can_set_logistic_filter(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         set_logistic_filter(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         set_logistic_filter(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         set_logistic_filter(nil, chest, pindex)
      end
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building",pindex)
   else
      --Other menu
      printout("No actions",pindex)
   end
end

function logistics_request_decrement_min_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_decrement_min(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_decrement_min(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_decrement_min(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_decrement_min(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions",pindex)
      end
   elseif players[pindex].menu == "building" and can_set_logistic_filter(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         set_logistic_filter(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         set_logistic_filter(stack, chest, pindex)
      else
         --Empty hand, empty inventory slot
         set_logistic_filter(nil, chest, pindex)
      end
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building",pindex)
   else
      --Other menu
      printout("No actions",pindex)
   end
end

function logistics_request_increment_max_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_increment_max(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_increment_max(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   else
      --Other menu
      --(do nothing)
   end
end

function logistics_request_decrement_max_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_decrement_max(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_decrement_max(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   else
      --Other menu
      --(do nothing)
   end
end

function logistics_request_toggle_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      logistics_request_toggle_personal_logistics(pindex)
   else
      local ent = game.get_player(pindex).opened
      if can_make_logistic_requests(ent) then
         ent.request_from_buffers = not ent.request_from_buffers
      else
         return 
      end
      if ent.request_from_buffers then
         printout("Enabled requesting from buffers", pindex)
      else
         printout("Disabled requesting from buffers", pindex)
      end
   end
end

--Returns summary info string
function player_logistic_requests_summary_info(pindex)
   --***maybe use logistics_networks_info(ent,pos_in)
   --***todo "y of z personal logistic requests fulfilled, x items in trash, missing items include [3], take an item in hand and press L to check its request status."
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched == true then
         printout("Logistic requests not available, research required.",pindex)
         return
      end
   end
   
   --Check if inside any logistic network or not (simpler than logistics network info)
   local network = p.surface.find_logistic_network_by_position(p.position, p.force)
   if network == nil or not network.valid then
      result = result .. "Not in a network, "
   end
   
   --Check if personal logistics are enabled
   if not p.character_personal_logistic_requests_enabled then
      result = result .. "Requests paused, "
   end
   
   --Count logistics requests
   result = result .. count_active_personal_logistic_slots(pindex) .. " personal logistic requests set, "
   return result
end

--Read the current personal logistics request set for this item
function player_logistic_request_read(item_stack,pindex,additional_checks)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Logistic requests not available, research required.",pindex)
         return
      end
   end
   
   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local network = p.surface.find_logistic_network_by_position(p.position, p.force)
      if network == nil or not network.valid then
         result = result .. "Not in a network, "
      end
      
      --Check if personal logistics are enabled
      if not p.character_personal_logistic_requests_enabled then
         result = result .. "Requests paused, "
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == nil or correct_slot_id < 1 then
      printout(result .. "Error: Invalid slot ID",pindex)
      return 
   end
   
   --Read the correct slot id value
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout(result .. "No personal logistic requests set for " .. item_stack.name .. ", use the L key and modifier keys to set requests.",pindex)
      return
   else
      --Report request counts and inventory counts
      if current_slot.max ~= nil or current_slot.min ~= nil then
         local min_result = ""
         local max_result = ""
         local inv_result = ""
         local trash_result = ""
         
         if current_slot.min ~= nil then
            min_result = get_unit_or_stack_count(current_slot.min, item_stack.prototype.stack_size, false) .. " minimum and "
         end
         
         if current_slot.max ~= nil then
            max_result = get_unit_or_stack_count(current_slot.max, item_stack.prototype.stack_size, false) .. " maximum "
         end
         
         local inv_count = p.get_main_inventory().get_item_count(item_stack.name)
         inv_result = get_unit_or_stack_count(inv_count, item_stack.prototype.stack_size, false) .. " in inventory, "
         
         local trash_count = p.get_inventory(defines.inventory.character_trash).get_item_count(item_stack.name)
         trash_result = get_unit_or_stack_count(trash_count, item_stack.prototype.stack_size, false) .. " in personal trash, "
         
         printout(result .. min_result .. max_result .. " requested for " .. item_stack.name .. ", " .. inv_result .. trash_result .. " use the L key and modifier keys to set requests.",pindex)
         return
      else
         --All requests are nil
         printout(result .. "No personal logistic requests set for " .. item_stack.name .. ", use the L key and modifier keys to set requests.",pindex)
         return
      end
   end
end

--Returns a quantity of an item in terms of stacks, if there is at least one stack
function get_unit_or_stack_count(count,stack_size,precise)
   local result = ""
   local new_count = "unknown amount of"
   local units = " units "
   if count == nil then
      new_count = "no"
   elseif count == 0 then 
      units = " units "
      new_count = 0
   elseif count == 1 then 
      units = " unit "
      new_count = 1
   elseif count < stack_size  then 
      units = " units "
      new_count = count
   elseif count == stack_size then
      units = " stack "
      new_count = 1
   elseif count > stack_size then
      units = " stacks "
      new_count = math.floor(count / stack_size)
   end
   result = new_count .. units
   if precise and count > stack_size and count % stack_size > 0 then
      result = result .. " and " .. count % stack_size .. " units "
   end
   if count > 10000 then
      result = "infinite"
   end
   return result
end

function player_logistic_request_increment_min(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 1, max = nil}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.min = increment_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex,false)
end

function player_logistic_request_decrement_min(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = nil}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.min = decrement_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex)
end

function player_logistic_request_increment_max(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = MAX_STACK_COUNT * item_stack.prototype.stack_size}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.max = increment_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex)
end

function player_logistic_request_decrement_max(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = MAX_STACK_COUNT * item_stack.prototype.stack_size}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.max = decrement_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex,false)
end

--Finds or assigns the logistic request slot for the item
function get_chest_logistic_slot_index(item_stack,chest)
   local slots_max_count = chest.request_slot_count
   local slot_found = false
   local current_slot = nil
   local correct_slot_id = nil
   local slot_id = 0
   
   --Find the correct request slot for this item, if any
   while not slot_found and slot_id < slots_max_count do
      slot_id = slot_id + 1
      current_slot = chest.get_request_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         --do nothing
      elseif current_slot.name == item_stack.name then
         slot_found = true
         correct_slot_id = slot_id
      else
         --do nothing
      end
   end
   
   --If needed, find the first empty slot and set it as the correct one
   if not slot_found then
      slot_id = 0
      while not slot_found and slot_id < 100 do
         slot_id = slot_id + 1
         current_slot = chest.get_request_slot(slot_id)
         if current_slot == nil or current_slot.name == nil then
            slot_found = true
            correct_slot_id = slot_id
         else
            --do nothing
         end
      end
   end
   
   --If no correct or empty slots found then return with error (all slots full)
   if not slot_found then
      return -1
   end
   
   return correct_slot_id
end

--Read the chest's current logistics request set for this item
function chest_logistic_request_read(item_stack,chest,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_chest_logistic_slot_index(item_stack,chest)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end

   --Read the correct slot id value
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout("No logistic requests set for " .. item_stack.name .. ", use the 'L' key and modifier keys to set requests.",pindex)
      return
   else
      --Report request counts and inventory counts
      local req_result = ""
      local inv_result = ""
      
      if current_slot.count ~= nil then
         req_result = get_unit_or_stack_count(current_slot.count, item_stack.prototype.stack_size, false) 
      end
      
      local inv_count = chest.get_output_inventory().get_item_count(item_stack.name)
      inv_result = get_unit_or_stack_count(inv_count, item_stack.prototype.stack_size, false) 
      
      printout(req_result .. " requested and " .. inv_result .. " supplied for " .. item_stack.name .. ", use the 'L' key and modifier keys to set requests.",pindex)
      return
   end
end

--Increments min value
function chest_logistic_request_increment_min(item_stack,chest,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_chest_logistic_slot_index(item_stack,chest)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, count = item_stack.prototype.stack_size}
      chest.set_request_slot(new_slot, correct_slot_id)
   else
      --Update existing request
      current_slot.count = increment_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.count)
      chest.set_request_slot(current_slot,correct_slot_id)
   end
   
   --Read new status
   chest_logistic_request_read(item_stack,chest,pindex,false)
end

--Decrements min value
function chest_logistic_request_decrement_min(item_stack,chest, pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_chest_logistic_slot_index(item_stack,chest)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, count = item_stack.prototype.stack_size}
      chest.set_request_slot(new_slot, correct_slot_id)
   else
      --Update existing request
      current_slot.count = decrement_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.count)
      if current_slot.count == nil or current_slot.count == 0 then 
         chest.clear_request_slot(correct_slot_id)
      else
         chest.set_request_slot(current_slot,correct_slot_id)
      end
   end
   
   --Read new status
   chest_logistic_request_read(item_stack,chest,pindex,false)
end

--Checks logistic roles
function can_make_logistic_requests(ent)
   if ent == nil or ent.valid == false then
      return false
   end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil or point.valid == false then 
      return false
   end
   if point.mode == defines.logistic_mode.requester or point.mode == defines.logistic_mode.buffer then
      return true
   else
      return false 
   end
end

function can_set_logistic_filter(ent)
   if ent == nil or ent.valid == false then
      return false
   end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil or point.valid == false then 
      return false
   end
   if point.mode == defines.logistic_mode.storage then
      return true
   else
      return false 
   end
end

function set_logistic_filter(stack, ent, pindex)
   if stack == nil or stack.valid_for_read == false then
      ent.storage_filter = nil
      printout("logistic storage filter cleared",pindex)
      return
   end
   
   if ent.storage_filter == stack.prototype then
      ent.storage_filter = nil
      printout("logistic storage filter cleared",pindex)
   else
      ent.storage_filter = stack.prototype
      printout(stack.name .. " set as logistic storage filter ",pindex)
   end
end

function read_chest_requests_summary(ent,pindex)--***todo improve
   printout(ent.request_slot_count .. " chest logistic requests set", pindex)
end

--Finds the nearest roboport
function find_nearest_roboport(surf,pos,radius_in)
   local nearest = nil
   local min_dist = radius_in
   local ports = surf.find_entities_filtered{name = "roboport" , position = pos , radius = radius_in}
   for i,port in ipairs(ports) do
      local dist = math.ceil(util.distance(pos, port.position))
      if dist < min_dist then
         min_dist = dist
         nearest = port
      end
   end
   if nearest ~= nil then
      rendering.draw_circle{color = {1, 1, 0}, radius = 4, width = 4, target = nearest.position, surface = surf, time_to_live = 90}
   end
   return nearest, min_dist
end

--laterdo** maybe use surf.find_closest_logistic_network_by_position(position, force)

--The idea is that every roboport of the network has the same backer name and this is the networks's name.
function get_network_name(port)
   resolve_network_name(port)
   return port.backer_name
end


--Sets a logistic network's name. The idea is that every roboport of the network has the same backer name and this is the networks's name.
function set_network_name(port,new_name)
   --Rename this port
   if new_name == nil or new_name == "" then
      return false
   end
   port.backer_name = new_name
   --Rename the rest, if any
   local nw = port.logistic_network
   if nw == nil then
      return true
   end
   local cells = nw.cells
   if cells == nil or cells == {} then
      return true
   end
   for i,cell in ipairs(cells) do
      if cell.owner.supports_backer_name then
         cell.owner.backer_name = new_name
      end
   end
   return true
end

--Finds the oldest roboport and applies its name across the network. Any built roboport will be newer and so the older names will be kept.
function resolve_network_name(port_in)
   local oldest_port = port_in
   local nw = oldest_port.logistic_network
   --No network means resolved
   if nw == nil then
      return 
   end
   local cells = nw.cells
   --Check others
   for i,cell in ipairs(cells) do
      local port = cell.owner
      if port ~= nil and port.valid and oldest_port.unit_number > port.unit_number then
         oldest_port = port
      end
   end
   --Rename all
   set_network_name(oldest_port, oldest_port.backer_name)
   return 
end

--[[--Logistic network menu options summary 
   0. Roboport of logistic network NAME, instructions
   1. Rename roboport network
   2. This roboport: Check neighbor counts and dirs
   3. This roboport: Check contents
   4. Check network roboport & robot & chest(?) counts
   5. Ongoing jobs info
   6. Check network item contents

   This menu opens when you click on a roboport.
]]
function roboport_menu(menu_index, pindex, clicked)--****
   local index = menu_index
   local port = nil
   local ent = get_selected_ent(pindex)
   if game.get_player(pindex).opened ~= nil and game.get_player(pindex).opened.name == "roboport" then
      port = game.get_player(pindex).opened
      players[pindex].roboport_menu.port = port
   elseif ent ~= nil and ent.valid and ent.name == "roboport" then
      port = ent
      players[pindex].roboport_menu.port = port
   else
      players[pindex].roboport.port = nil
      printout("Roboport menu requires a roboport", pindex)
      return
   end
   local nw = port.logistic_network
   
   if index == 0 then
      --0. Roboport of logistic network NAME, instructions
      printout("Roboport of logistic network ".. get_network_name(port)
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --1. Rename roboport networks
      if not clicked then
         printout("Click here to rename this network", pindex)
      else
         printout("Enter a new name for this network, then press 'ENTER' to confirm.", pindex)
         players[pindex].roboport_menu.renaming = true
         local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "network-rename"}
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         --game.get_player(pindex).opened = frame
         local input = frame.add{type="textfield", name = "input"}
         input.focus()
      end
   elseif index == 2 then
      --2. This roboport: Check neighbor counts and dirs
      if clicked or (not clicked) then
         local result = roboport_neighbours_info(port)
         printout("Roboport has " .. result, pindex)
      end
   elseif index == 3 then
      --3. This roboport: Check robot counts
      if clicked or (not clicked) then
         local result = roboport_contents_info(port)
         printout("Roboport " .. result, pindex)
      end
   elseif index == 4 then
      --4. Check network roboport & robot & chest(?) counts
      if nw ~= nil then
         local result = logistic_network_members_info(port)
         printout(result, pindex)
      else
         printout("Robots: No network", pindex)
      end
   elseif index == 5 then
      --5. Points/chests info
      if nw ~= nil then
         local result = logistic_network_chests_info(port)
         printout(result, pindex)
      else
         printout("Chests: No network", pindex)
      end
   elseif index == 6 then
      --6. Check network item contents
      if nw ~= nil then
         local result = logistic_network_items_info(port)
         printout(result, pindex)
      else
         printout("Items: No network", pindex)
      end
   end
end
ROBOPORT_MENU_LENGTH = 6

function roboport_menu_open(pindex)
   if players[pindex].vanilla_mode then
      return 
   end
   --Set the player menu tracker to this menu
   players[pindex].menu = "roboport_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Initialize if needed
   if players[pindex].roboport_menu == nil then
      players[pindex].roboport_menu = {}
   end
   --Set the menu line counter to 0
   players[pindex].roboport_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function roboport_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].roboport_menu.index = 0
   players[pindex].roboport_menu.port = nil
   
   --play sound
   if not mute then
      game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}
   end
   
   --Destroy GUI
   if game.get_player(pindex).gui.screen["network-rename"] ~= nil then
      game.get_player(pindex).gui.screen["network-rename"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then
      game.get_player(pindex).opened = nil
   end
end

function roboport_menu_up(pindex)
   players[pindex].roboport_menu.index = players[pindex].roboport_menu.index - 1
   if players[pindex].roboport_menu.index < 0 then
      players[pindex].roboport_menu.index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function roboport_menu_down(pindex)
   players[pindex].roboport_menu.index = players[pindex].roboport_menu.index + 1
   if players[pindex].roboport_menu.index > ROBOPORT_MENU_LENGTH then
      players[pindex].roboport_menu.index = ROBOPORT_MENU_LENGTH
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function roboport_contents_info(port)
   local result = ""
   local cell = port.logistic_cell
   result = result .. " charging " .. cell.charging_robot_count .. " robots with " .. cell.to_charge_robot_count .. " in queue, " .. 
            " stationed " .. cell.stationed_logistic_robot_count .. " logistic robots and " .. cell.stationed_construction_robot_count .. " construction robots " ..
            " and " .. port.get_inventory(defines.inventory.roboport_material).get_item_count() .. " repair packs "
   return result
end

function roboport_neighbours_info(port)
   local result = ""
   local cell = port.logistic_cell
   local neighbour_count = #cell.neighbours
   local neighbour_dirs = ""
   for i, neighbour in ipairs(cell.neighbours) do 
      local dir = direction_lookup(get_direction_of_that_from_this(neighbour.owner.position, port.position))
      if i > 1 then
         neighbour_dirs = neighbour_dirs .. " and "
      end
      neighbour_dirs = neighbour_dirs .. dir 
   end
   if neighbour_count > 0 then 
      result = neighbour_count .. " neighbours" .. ", at the " .. neighbour_dirs
   else
      result = neighbour_count .. " neighbours"
   end
   
   return result
end

function logistic_network_members_info(port)
   local result = ""
   local cell = port.logistic_cell
   local nw = cell.logistic_network
   
   result = " Robots: Network has " .. #nw.cells .. " roboports, and " .. nw.all_logistic_robots .. " logistic robots with " .. nw.available_logistic_robots .. " available, and " ..
            nw.all_construction_robots .. " construction robots with " .. nw.available_construction_robots .. " available "
   return result
end

function logistic_network_chests_info(port)
   local result = ""
   local cell = port.logistic_cell
   local nw = cell.logistic_network
   
   local storage_chest_count = 0
   for i,ent in ipairs(nw.storage_points) do 
      if ent.owner.type == "logistic-container" then
         storage_chest_count = storage_chest_count + 1
      end
   end
   local passive_provider_chest_count = 0
   for i,ent in ipairs(nw.passive_provider_points) do 
      if ent.owner.type == "logistic-container" then
         passive_provider_chest_count = passive_provider_chest_count + 1
      end
   end
   local active_provider_chest_count = 0
   for i,ent in ipairs(nw.active_provider_points) do 
      if ent.owner.type == "logistic-container" then
         active_provider_chest_count = active_provider_chest_count + 1
      end
   end
   local requester_chest_count = 0
   for i,ent in ipairs(nw.requester_points) do 
      if ent.owner.type == "logistic-container" then
         requester_chest_count = requester_chest_count + 1
      end
   end
   
   result = " Chests: Network has " .. storage_chest_count .. " storage chests, " .. 
            passive_provider_chest_count .. " passive provider chests, " .. 
            active_provider_chest_count .. " active provider chests, " .. 
            requester_chest_count .. " requester chests or buffer chests, "
   --game.print(result,{volume_modifier=0})--***
   return result
end

function logistic_network_items_info(port)
   local result = "Items: Network "
   local itemset = port.logistic_cell.logistic_network.get_contents()
   local itemtable = {}
   for name, count in pairs(itemset) do
      table.insert(itemtable, {name = name, count = count})
   end
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable == 0 then
      result = result .. " contains no items. "
   else
      result = result .. " contains " .. itemtable[1].name .. " times " .. itemtable[1].count .. ", "
      if #itemtable > 1 then
         result = result .. " and " .. itemtable[2].name .. " times " .. itemtable[2].count .. ", "
      end
      if #itemtable > 2 then
         result = result .. " and " .. itemtable[3].name .. " times " .. itemtable[3].count .. ", "
      end
      if #itemtable > 3 then
         result = result .. " and " .. itemtable[4].name .. " times " .. itemtable[4].count .. ", "
      end
      if #itemtable > 4 then
         result = result .. " and " .. itemtable[5].name .. " times " .. itemtable[5].count .. ", "
      end
      if #itemtable > 5 then
         result = result .. " and other items "
      end
   end
   return result
end

--laterdo vehicle logistic requests...

--laterdo add or remove stacks from player trash

--laterdo full personal logistics menu where you can go line by line along requests and edit them, iterate through trash?
