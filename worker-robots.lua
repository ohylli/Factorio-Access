dirs = defines.direction

--https://lua-api.factorio.com/latest/classes/LuaLogisticCell.html
--defines.inventory.character_trash

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
   rendering.draw_circle{color = {1, 1, 0}, radius = 4, width = 4, target = nearest.position, surface = surf, time_to_live = 90}
   return nearest, min_dist
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function increment_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in
   
   if amount_min == nil or amount_min == 0 then
      amount_min = 1
   elseif amount_min == 1 then
      amount_min = math.floor(stack_size/2)
   elseif amount_min == math.floor(stack_size/2) then
      amount_min = stack_size
   elseif amount_min == stack_size then
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
   elseif amount_min == math.floor(stack_size/2) then
      amount_min = 1
   elseif amount_min == stack_size then
      amount_min = math.floor(stack_size/2)
   elseif amount_min > stack_size then
      amount_min = amount_min - stack_size
   end
   
   return amount_min
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function increment_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in
   
   if amount_max ~= nil and amount_max > stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max ~= nil and amount_max == stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max ~= nil and amount_max == math.floor(stack_size/2) then
      amount_max = stack_size
   elseif amount_max ~= nil and amount_max == 1 then
      amount_max = math.floor(stack_size/2)
   elseif amount_max == nil or amount_max == 0 then
      amount_max = 1
   end
   
   return amount_max
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function decrement_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_min = amount_min_in
   local amount_max = amount_max_in
   
   if amount_max ~= nil and amount_max > stack_size then
      amount_max = amount_max - stack_size
   elseif amount_max ~= nil and amount_max == stack_size then
      amount_max = math.floor(stack_size/2)
   elseif amount_max ~= nil and amount_max == math.floor(stack_size/2) then
      amount_max = 1
   elseif amount_max ~= nil and amount_max == 1 then
      amount_max = nil
   elseif amount_max == nil or amount_max == 0 then
      amount_max = nil
   end
   
   return amount_max
end

function logistics_request_toggle_personal_logistics(pindex)
   local p = game.get_player(pindex)
   p.character_personal_logistic_requests_enabled = not p.character_personal_logistic_requests_enabled
   if p.character_personal_logistic_requests_enabled then
      printout("Personal logistics requests enabled",pindex)
   else
      printout("Personal logistics requests paused",pindex)
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
         --Empty hand and empty inventory slot
         local result = player_logistic_requests_summary_info(pindex)
         printout(result,pindex)
      end
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
   else
      --Other menu
      --(do nothing)
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
   else
      --Other menu
      --(do nothing)
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
      if tech.name == "logistic-robotics" and not tech.researched then
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
   result = result .. count_active_personal_logistic_slots(pindex) .. " logistic requests set, "
   return result
end

--laterdo full personal logistics menu where you can go line by line along requests and edit them, iterate through trash?

function player_logistic_requests_clear_all(pindex)
   --***todo
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
   
   --Read the correct slot id value, increment it, set it
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
      return true
   else
      --Update existing request
      current_slot.min = increment_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
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
      local new_slot = {name = item_stack.name, min = nil, max = 1}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
      return true
   else
      --Update existing request
      current_slot.min = decrement_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
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
      local new_slot = {name = item_stack.name, min = nil, max = 1}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
      return true
   else
      --Update existing request
      current_slot.max = increment_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
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
      local new_slot = {name = item_stack.name, min = 1, max = nil}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
      return true
   else
      --Update existing request
      current_slot.max = decrement_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex,false)
end


--Read the chest's current logistics request set for this item
function chest_logistic_request_read(item_stack,chest_ent,additional_checks)

end

--Increments min value, but if its nil, decrements MAX value
function chest_logistic_request_increment(item_stack,chest_ent)
   --...
end

--Decrements min value, but if its nil, increments MAX value
function chest_logistic_request_decrement(item_stack,chest_ent)
   --...
end

--laterdo vehicle logistic requests...

--todo: add to trash***, restore all trash*** 
