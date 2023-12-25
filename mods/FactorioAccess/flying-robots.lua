dirs = defines.direction

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
function increment_logistic_request_min_amount(item, amount_min_in)
   local stack_size = item.stack_size
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
function decrement_logistic_request_min_amount(item, amount_min_in)
   local stack_size = item.stack_size
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
function increment_logistic_request_max_amount(item, amount_max_in)
   local stack_size = item.stack_size
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
function decrement_logistic_request_max_amount(item, amount_max_in)
   local stack_size = item.stack_size
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

function toggle_player_logistic_requests_enabled(pindex)
   local p = game.get_player(pindex)
   character_personal_logistic_requests_enabled = not character_personal_logistic_requests_enabled
   if p.character_personal_logistic_requests_enabled then
      printout("Personal logistics requests enabled",pindex)
   else
      printout("Personal logistics requests paused",pindex)
   end   
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

function player_logistic_request_read(item_stack,pindex,additional_checks)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use personal logistic requests.",pindex)
         return
      end
   end
   
   
   if additional_checks then
      --Check if in range of a logistic network ***
      
      --If not, report nearest logistic network ***
      
      --Check if personal logistics are enabled
      if not p.character_personal_logistic_requests_enabled then
         result = result .. " Requests paused, "
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
      --Read
      printout(result .. "No personal logistic requests set for " .. item_stack.name .. ", Press SHIFT + L to increase the minimum target item count, or Press CONTROL + L to increase the maximum target item count.",pindex)
   else
      --Update existing request
      if current_slot.max ~= nil and current_slot.max > 0 then
         local count = current_slot.max
         local units = " units "
         if count > item_stack.stack_size then
            units = " stacks "
            count = math.floor(count / item_stack.stack_size)
         end
         printout(result .. "Maximum of " .. count .. units .. "requested for " .. item_stack.name .. ", Press SHIFT + L to decrease this maximum target item count, or Press CONTROL + L to increase it.",pindex)
      elseif current_slot.min ~= nil and current_slot.min > 0 then
         local count = current_slot.min
         local units = " units "
         if count > item_stack.stack_size then
            units = " stacks "
            count = math.floor(count / item_stack.stack_size)
         end
         printout(result .. "Minimum of " .. count .. units .. "requested for " .. item_stack.name .. ", Press SHIFT + L to increase this minimum target item count, or Press CONTROL + L to decrease it.",pindex)
      else--Both are nil
         printout(result .. "No personal logistic requests set for " .. item_stack.name .. ", Press SHIFT + L to increase the minimum target item count, or Press CONTROL + L to increase the maximum target item count.",pindex)
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
end

--Increments min value, but if its nil, decrements MAX value
function player_logistic_request_increment(item_stack,pindex)
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
      if current_slot.max ~= nil then
         current_slot.max = decrement_logistic_request_max_amount(item_stack,current_slot.max)
      elseif current_slot.min ~= nil then
         current_slot.min = increment_logistic_request_min_amount(item_stack,current_slot.min)
      else--Both are nil
         current_slot.min = 1
         current_slot.max = nil
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex,false)
end

--Decrements min value, but if its nil, increments MAX value
function player_logistic_request_decrement(item_stack,pindex)
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
      if current_slot.max ~= nil then
         current_slot.max = increment_logistic_request_max_amount(item_stack,current_slot.max)
      elseif current_slot.min ~= nil then
         current_slot.min = decrement_logistic_request_min_amount(item_stack,current_slot.min)
      else--Both are nil
         current_slot.min = nil
         current_slot.max = 1
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot,false)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex)
end

--Increments min value, but if its nil, decrements MAX value
function chest_logistic_request_increment(item_stack,chest_ent)
   --...
end

--Decrements min value, but if its nil, increments MAX value
function chest_logistic_request_decrement(item_stack,chest_ent)
   --...
end