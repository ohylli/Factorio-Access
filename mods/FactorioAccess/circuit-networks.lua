--Here: Functions relating to circuit networks, virtual signals, wiring and unwiring buildings, and the such.
--Does not include event handlers directly, but can have functions called by them.
local dcb = defines.control_behavior

function drag_wire_and_read(pindex)
   --Start/end dragging wire 
   local p = game.get_player(pindex)
   local something_happened = p.drag_wire{position = players[pindex].cursor_pos}
   --Comment on it
   if something_happened == true then
      local result = ""
      local wire_type = nil 
      local wire_name = "wire"
      if p.cursor_stack.valid_for_read then 
         wire_type = p.cursor_stack.name 
         wire_name = localising.get(p.cursor_stack,pindex)
         players[pindex].last_wire_type = wire_type
         players[pindex].last_wire_name = wire_name
      else
         wire_type = players[pindex].last_wire_type
         wire_name = players[pindex].last_wire_name
      end
      
      local drag_target = p.drag_target
      local ents_at_position = p.surface.find_entities_filtered{position = players[pindex].cursor_pos, radius = 0.2, type = {"transport-belt", "inserter", "container", "logistic-container", "storage-tank", "gate", "rail-signal", "rail-chain-signal", "train-stop", "accumulator", "roboport", "mining-drill", "pumpjack", "power-switch", "programmable-speaker", "lamp", "offshore-pump", "pump", "electric-pole"}}
      local c_ent = ents_at_position[1]
      local last_c_ent = players[pindex].last_wire_ent
      local network_found = nil
      if c_ent == nil or c_ent.valid == false then
         c_ent = p.selected
      end
      if c_ent == nil or c_ent.valid == false then
         result = wire_name .. " , " .. " no ent "
      elseif wire_type == "red-wire" then
         if drag_target ~= nil then
            local target_ent = drag_target.target_entity
            local target_network = drag_target.target_circuit_id
            network_found = c_ent.get_circuit_network(defines.wire_type.red, target_network)
            if network_found == nil or network_found.valid == false then
               network_found = "nil"
            else
               network_found = network_found.network_id
            end
            result = " Connected " .. localising.get(target_ent,pindex) .. " to red circuit network ID " .. network_found 
         else
            result = " Disconnected " .. wire_name 
         end
      elseif wire_type == "green-wire" then
         if drag_target ~= nil then
            local target_ent = drag_target.target_entity
            local target_network = drag_target.target_circuit_id
            network_found = c_ent.get_circuit_network(defines.wire_type.green, target_network)
            if network_found == nil or network_found.valid == false then
               network_found = "nil"
            else
               network_found = network_found.network_id
            end
            result = " Connected " .. localising.get(target_ent,pindex) .. " to green circuit network ID " .. network_found 
         else
            result = " Disconnected " .. wire_name 
         end
      elseif wire_type == "copper-cable" then
         if drag_target ~= nil then
            local target_ent = drag_target.target_entity
            local target_network = drag_target.target_wire_id
            network_found = c_ent.electric_network_id
            if network_found == nil then
               network_found = "nil"
            end
            result = " Connected " .. localising.get(target_ent,pindex) .. " to electric network ID " .. network_found 
         elseif (c_ent ~= nil and c_ent.name == "power-switch") or (last_c_ent ~= nil and last_c_ent.valid and last_c_ent.name == "power-switch") then 
            network_found = c_ent.electric_network_id
            if network_found == nil then
               network_found = "nil"
            end
               result = " Wiring power switch"
            --result = " Connected " .. localising.get(c_ent,pindex) .. " to electric network ID " .. network_found 
         else
            result = " Disconnected " .. wire_name 
         end
      end
      p.print(result)--***
      printout(result, pindex)
   else
      p.play_sound{path = "utility/cannot_build"}
   end
   players[pindex].last_wire_ent = c_ent
end

--**** test ent.circuit_connected_entities and ent.circuit_connection_definitions

function wire_neighbours_info(ent, read_network_ids)
   --List connected electric poles
   local neighbour_count = 0
   local result = ""
   if (#ent.neighbours.copper + #ent.neighbours.red + #ent.neighbours.green) == 0 then
      result = result .. " with no connections, "
   else
      result = result .. " connected to "
      for i,pole in ipairs(ent.neighbours.copper) do
         local dir = get_direction_of_that_from_this(pole.position,ent.position)
         local dist = util.distance(pole.position,ent.position)
         if neighbour_count > 0 then
            result = result .. " and "
         end
         local id = pole.electric_network_id
         if id == nil then
            id = "nil"
         end
         result = result .. math.ceil(dist) .. " tiles " .. direction_lookup(dir) 
         if read_network_ids == true then 
            result = result .. " to electric network number " .. id
         end
         result = result .. ", "
         neighbour_count = neighbour_count + 1
      end
      for i,nbr in ipairs(ent.neighbours.red) do
         local dir = get_direction_of_that_from_this(nbr.position,ent.position)
         local dist = util.distance(nbr.position,ent.position)
         if neighbour_count > 0 then
            result = result .. " and "
         end
         result = result .. " red wire " .. math.ceil(dist) .. " tiles " .. direction_lookup(dir)
         if nbr.type == "electric-pole" then 
            local id = nbr.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.electric_pole)
            if id == nil then
               id = "nil"
            else
               id = id.network_id
            end
            if read_network_ids == true then 
               result = result .. " network number " .. id
            end
         end
         result = result .. ", "
         neighbour_count = neighbour_count + 1
      end
      for i,nbr in ipairs(ent.neighbours.green) do
         local dir = get_direction_of_that_from_this(nbr.position,ent.position)
         local dist = util.distance(nbr.position,ent.position)
         if neighbour_count > 0 then
            result = result .. " and "
         end
         result = result .. " green wire " .. math.ceil(dist) .. " tiles " .. direction_lookup(dir) 
         if nbr.type == "electric-pole" then 
            local id = nbr.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.electric_pole)
            if id == nil then
               id = "nil"
            else
               id = id.network_id
            end
            if read_network_ids == true then 
               result = result .. " network number " .. id
            end
         end
         result = result .. ", "
         neighbour_count = neighbour_count + 1
      end
   end
   return result 
end

function localise_signal_name(signal,pindex)--todo*** actually localise
   if signal == nil then
      return "nil"
   end
   local sig_name = signal.name
   local sig_type = signal.type
   if sig_name == nil then
      sig_name = "nil"
      sig_type = "nil"
   end
   if sig_type == nil then
      sig_type = "nil"
   end
   local result = (sig_name .. " " .. sig_type) 
   return result 
end

function constant_combinator_count_valid_signals(ent)
   local count = 0
   local combinator = ent.get_control_behavior()
   local max_signals_count = combinator.signals_count
   for i = 1,max_signals_count,1 do 
      if combinator.get_signal(i).signal ~= nil then
         count = count + 1
      end
   end
   return count
end

function constant_combinator_get_first_empty_slot_id(ent)
   local combinator = ent.get_control_behavior()
   local max_signals_count = combinator.signals_count
   for i = 1,max_signals_count,1 do 
      if combinator.get_signal(i).signal == nil then
         return i
      end
   end
   return max_signals_count
end

function constant_combinator_signals_info(ent, pindex)
   local combinator = ent.get_control_behavior()
   local max_signals_count = combinator.signals_count
   local valid_signals_count = constant_combinator_count_valid_signals(ent)
   local result = nil
   if combinator.enabled then
      result = " switched on, "
   else
      result = " switched off, "
   end
   if valid_signals_count == 0 then
      result = result .. " with no signals "
   else
      result = result .. " with signals " 
      for i = 1,max_signals_count,1 do 
         local signal = combinator.get_signal(i)
         if signal.signal ~= nil then
            local signal_name = localise_signal_name(signal.signal,pindex)
            if i > 1 then
               result = result .. " and "
            end   
            result = result .. signal_name .. " times " .. signal.count .. ", "
         end
      end
   end
   --game.print(result)--
   return result 
end

function constant_combinator_add_stack_signal(ent, stack, pindex)
   local combinator = ent.get_control_behavior()
   local first_empty_slot = constant_combinator_get_first_empty_slot_id(ent)
   local new_signal_id = {type = "item", name = stack.name}
   local new_signal  = {signal = new_signal_id, count = 1}
   combinator.set_signal(first_empty_slot, new_signal)
   printout("Added signal for " .. localising.get(stack, pindex), pindex)
end

function constant_combinator_remove_last_signal(ent, pindex)
   local combinator = ent.get_control_behavior()
   local max_signals_count = combinator.signals_count
   for i = max_signals_count,1,-1 do 
      local signal = combinator.get_signal(i)
      if signal.signal ~= nil then
         local signal_name = localise_signal_name(signal.signal,pindex)
         printout("Removed last signal " .. signal_name, pindex)
         combinator.set_signal(i , nil)
         return
      end
   end
   printout("No signals to remove", pindex)
end

function get_circuit_read_mode_name(ent)
   local result = "None"
   local control = ent.get_control_behavior()
   if ent.type == "inserter" then
      if control.circuit_read_hand_contents == true then
         if control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.hold then
            result = "Reading held items" 
         elseif control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.pulse then
            result = "pulsing passing items" 
         end
      end
   elseif ent.type == "transport-belt" then
      if control.read_contents == true then
         if control.read_contents_mode == dcb.transport_belt.content_read_mode.hold then
            result = "Reading held items" 
         elseif control.read_contents_mode == dcb.transport_belt.content_read_mode.pulse then
            result = "pulsing passing items"
         end
      end
   elseif ent.type == "container" or ent.type == "logistic-container" or ent.type == "storage-tank" then
      result = "Reading contents"
   elseif ent.type == "gate" then
      result = "Reading player presence in virtual signal G"
   elseif ent.type == "rail-signal" or ent.type == "rail-chain-signal" then
      result = "Reading virtual color signals for rail signal states"
   elseif ent.type == "train-stop" then
      result = "Reading train ID in virtual signal T and en route train count in virtual signal C" 
   elseif ent.type == "accumulator" then
      result = "Reading charge percentage in virtual signal A"
   elseif ent.type == "roboport" then
      result = "Reading something "--todo explain other read modes***
   elseif ent.type == "mining-drill" then
      result = "Reading something "--todo explain other read modes***
   elseif ent.type == "pumpjack" then
      result = "Reading something "--todo explain other read modes***
   end
   return result
end

function toggle_circuit_read_mode(ent)
   local result = ""
   local changed = false
   local control = ent.get_control_behavior()
   if ent.type == "inserter" then
      changed = true
      if control.circuit_read_hand_contents == false then
         control.circuit_read_hand_contents = true
         control.circuit_hand_read_mode = dcb.inserter.hand_read_mode.hold
         result = "Reading held items" 
      elseif control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.hold then
         control.circuit_read_hand_contents = true
         control.circuit_hand_read_mode = dcb.inserter.hand_read_mode.pulse
         result = "pulsing passing items"
      else --if control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.pulse then
         control.circuit_read_hand_contents = false
         result = "None"
      end
   elseif ent.type == "transport-belt" then 
      changed = true
      if control.read_contents == false then
         control.read_contents = true
         control.read_contents_mode = dcb.transport_belt.content_read_mode.hold 
         result = "Reading held items" 
      elseif control.read_contents_mode == dcb.transport_belt.content_read_mode.hold then
         control.read_contents = true
         control.read_contents_mode = dcb.transport_belt.content_read_mode.pulse
         result = "pulsing passing items"
      else --if control.read_contents_mode == dcb.transport_belt.content_read_mode.pulse then
         control.read_contents = false
         result = "None"
      end
   else
      changed = false
      result = get_circuit_read_mode_name(ent)--laterdo** allow toggling some other read modes
   end
   return result, changed
end

function get_circuit_operation_mode_name(ent)
   local result = "None"
   local uses_condition = false
   local control = ent.get_control_behavior()
   if ent.type == "inserter" then 
      if control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.none then
         result = "None"
      elseif control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.enable_disable then
         result = "Enable with condition"
         uses_condition = true
      elseif control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.read_hand_contents then
         result = "Only read hand contents"
      else
         result = "Other"
      end
   elseif ent.type == "transport-belt" then 
      if control.enable_disable == true then
         result = "Enable with condition"
         uses_condition = true
      else
         result = "None"
      end
   elseif ent.name == "logistic-requester-chest" then
      if control.circuit_mode_of_operation == dcb.logistic_container.circuit_mode_of_operation.set_requests then
         result = "Set logistic requests to match network signals"
      elseif control.circuit_mode_of_operation == dcb.logistic_container.circuit_mode_of_operation.send_contents then
         result = "Only read contents"
      else
         result = "Other"
      end
   elseif ent.type == "gate" then
      result = "Undefined"--**laterdo
   elseif ent.type == "rail-signal" then
      result = "Undefined"--**laterdo
   elseif ent.type == "train-stop" then
      result = "Undefined"--**laterdo
   elseif ent.type == "mining-drill" then
      result = "Undefined"--**laterdo
   elseif ent.type == "pumpjack" then
      result = "Undefined"--**laterdo
   elseif ent.type == "power-switch" then
      if control.circuit_condition ~= nil or control.disabled == true then
         result = "Enable with condition"
         uses_condition = true
      else
         result = "None"
      end
   elseif ent.type == "programmable-speaker" then
      result = "Undefined"--**laterdo
   elseif ent.type == "lamp" then
      result = "Undefined"--**laterdo
   elseif ent.type == "offshore-pump" then
      if control.circuit_condition ~= nil or control.disabled == true then
         result = "Enable with condition"
         uses_condition = true
      else
         result = "None"
      end
   elseif ent.type == "pump" then
      if control.circuit_condition ~= nil or control.disabled == true then
         result = "Enable with condition"
         uses_condition = true
      else
         result = "None"
      end
   else
      result = "None"
   end
   return result, uses_condition
end

function toggle_circuit_operation_mode(ent)
   local result = "None"
   local changed = false
   local control = ent.get_control_behavior()
   if ent.type == "inserter" then 
      changed = true
      if control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.none then
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.enable_disable
         result = "Enable with condition"
      elseif control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.enable_disable then
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.none
         result = "None"
      else
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.none
         result = "None"
      end
   elseif ent.type == "transport-belt" then 
      changed = true
      if control.enable_disable == true then
         control.enable_disable = false
         result = "None"
      else
         control.enable_disable = true
         result = "Enable with condition"
      end
   elseif ent.name == "logistic-requester-chest" then
      changed = true
      if control.circuit_mode_of_operation == dcb.logistic_container.circuit_mode_of_operation.set_requests then
         control.circuit_mode_of_operation = dcb.logistic_container.circuit_mode_of_operation.send_contents
         result = "Only read contents"
      elseif control.circuit_mode_of_operation == dcb.logistic_container.circuit_mode_of_operation.send_contents then
         control.circuit_mode_of_operation = dcb.logistic_container.circuit_mode_of_operation.set_requests
         result = "Set logistic requests to match network signals"
      else
         control.circuit_mode_of_operation = dcb.logistic_container.circuit_mode_of_operation.send_contents
         result = "Only read contents"
      end
   elseif ent.type == "gate" then
      result = "Undefined"--**laterdo
   elseif ent.type == "rail-signal" then
      result = "Undefined"--**laterdo
   elseif ent.type == "train-stop" then
      result = "Undefined"--**laterdo
   elseif ent.type == "mining-drill" then
      result = "Undefined"--**laterdo
   elseif ent.type == "pumpjack" then
      result = "Undefined"--**laterdo
   elseif ent.type == "power-switch" then
      changed = true
      if control.circuit_condition ~= nil or control.disabled == true then--**laterdo
         result = "Enable with condition"
      else
         result = "None"
      end
   elseif ent.type == "programmable-speaker" then
      result = "Undefined"--**laterdo
   elseif ent.type == "lamp" then
      result = "Undefined"--**laterdo
   elseif ent.type == "offshore-pump" then
      changed = true
      if control.circuit_condition ~= nil or control.disabled == true then--**laterdo
         result = "Enable with condition"
      else
         result = "None"
      end
   elseif ent.type == "pump" then
      changed = true
      if control.circuit_condition ~= nil or control.disabled == true then--**laterdo
         result = "Enable with condition"
      else
         result = "None"
      end
   else
      changed = false
      result = "None"
   end
   return result, changed
end

function read_circuit_condition(ent, comparator_in_words)
   local control = ent.get_control_behavior()
   local cond = control.circuit_condition.condition
   local fulfilled = control.circuit_condition.fulfilled
   local comparator = cond.comparator
   local first_signal_name = localise_signal_name(cond.first_signal,pindex)
   local second_signal_name = localise_signal_name(cond.second_signal,pindex)
   local result = ""
   if cond.second_signal == nil then
      second_signal_name = cond.constant
      if cond.constant == nil then
         second_signal_name = 0
      end
   end
   if comparator_in_words == true then
      if comparator == "=" then
         comparator = "equals"
      elseif comparator == "≠" then
         comparator = "not equals"
      elseif comparator == ">" then
         comparator = "greater than"
      elseif comparator == "≥" then
         comparator = "greater than or equal to"
      elseif comparator == "<" then
         comparator = "less than"
      elseif comparator == "≤" then
         comparator = "less than or equal to"
      else
         comparator = "compared to"
      end
   end
   local result = first_signal_name .. " " .. comparator .. " " .. second_signal_name
   return result 
end

function toggle_condition_comparator(ent, pindex, comparator_in_words)
   local circuit_condition = ent.get_control_behavior().circuit_condition
   local cond = circuit_condition.condition
   local comparator = cond.comparator
   if comparator == "=" then
      comparator = "≠"
   elseif comparator == "≠" then
      comparator = ">"
   elseif comparator == ">" then
      comparator = "≥"
   elseif comparator == "≥" then
      comparator = "<"
   elseif comparator == "<" then
      comparator = "≤"
   elseif comparator == "≤" then
      comparator = "="
   else
      comparator = "="
   end
   cond.comparator = comparator
   circuit_condition.condition = cond
   ent.get_control_behavior().circuit_condition = circuit_condition
   
   if comparator_in_words == true then
      if comparator == "=" then
         comparator = "equals"
      elseif comparator == "≠" then
         comparator = "not equals"
      elseif comparator == ">" then
         comparator = "greater than"
      elseif comparator == "≥" then
         comparator = "greater than or equal to"
      elseif comparator == "<" then
         comparator = "less than"
      elseif comparator == "≤" then
         comparator = "less than or equal to"
      else
         comparator = "compared to"
      end
   end
   
   return comparator
end

function write_condition_first_signal_item(circuit_condition, stack)
   local cond = circuit_condition.condition
   cond.first_signal = {type = "item", name = stack.name}
   return 
end

function write_condition_second_signal_item(circuit_condition, stack)
   local cond = circuit_condition.condition
   cond.second_signal = {type = "item", name = stack.name}
   return 
end

function write_condition_second_signal_constant(circuit_condition, constant)
   local cond = circuit_condition.condition
   cond.second_signal = nil
   cond.constant = constant
   return 
end

--[[ 
   Circuit network menu options summary
   
   All Ents
   0) Menu info: "<Ent> of Circuit Network <id_no> <color>" + instructions
   1) List all active signals of this network
   2) List all members of this network
   3) List network members directly connected to this building
   
   Electric Poles
   4) (Inventory edge, call 3)
   
   Other Ents
   4) Read machine behavior summary: "Reading none and enabled when X < Y"
   5) Toggle machine reading mode: None / Read held contents / Pulse passing contents
   6) Toggle machine control mode: None / Enabled condition
   7) Toggle enabled condition comparing rule: greater than / less than / equal to / not equal to
   8) Set enabled condition first signal from the signal selector
   9) Set enabled condition second signal from the signal selector
   10) Type in a constant for the Set enabled condition second signal

   This menu opens when you press KEY when a building menu is open.
]]
function circuit_network_menu(pindex, ent_in, menu_index, clicked, other_input)
   local index = menu_index
   local p = game.get_player(pindex)
   local ent = ent_in or p.opened
   if ent == nil or ent.valid == false then
      printout("Error: Missing entity" , pindex)
      return
   end
   --Get this ent's networks
   local nwr = ent.get_circuit_network(defines.wire_type.red)
   local nwg = ent.get_circuit_network(defines.wire_type.green)
   local nw_name = nil
   if nwr == nil and nwg == nil then
      printout("No circuit network connected", pindex)
      return 
   elseif nwr ~= nil and nwg == nil then 
      nw_name = " red " .. nwr.network_id
   elseif nwr == nil and nwg ~= nil then 
      nw_name = " green " .. nwg.network_id
   elseif nwr ~= nil and nwg ~= nil then 
      nw_name = " red " .. nwr.network_id .. " and green " .. nwg.network_id
   end
   
   --First 3 lines of the menus are in common
   if index == 0 then
      --Menu info
      local result = localising.get(ent,pindex) .. " in circuit network " .. nw_name
      .. ", Navigate up and down with 'W' and 'S' and select an option with 'LEFT BRACKET', or exit with 'ESC'"
      printout(result, pindex)
   elseif index == 1 then
      --List all active signals of this network
      if not clicked then
         printout("List active signals of this network",pindex)
      else
         local result = ""
         if nwr ~= nil then
            if nwg ~= nil then
               result = result .. "Red network: "
            end
            result = result .. circuit_network_signals_info(pindex, nwr)
         end
         if nwg ~= nil then
            if nwr ~= nil then
               result = result .. "Green network: "
            end
            result = result .. circuit_network_signals_info(pindex, nwg)
         end
         if result == "" then
            result = "No signals at the moment"
         end
         printout(result,pindex)
      end
   elseif index == 2 then
      --List all members of this network
      if not clicked then
         printout("List members of this network",pindex)
      else
         local result = ""
         if nwr ~= nil then
            if nwg ~= nil then
               result = result .. "Red network: "
            end
            result = result .. circuit_network_members_info(pindex, ent, defines.wire_type.red)
         end
         if nwg ~= nil then
            if nwr ~= nil then
               result = result .. "Green network: "
            end
            result = result .. circuit_network_members_info(pindex, ent, defines.wire_type.green)
         end
         if result == "" then
            result = "Error: No network"
         end
         printout(result,pindex)
      end
   elseif index == 3 then
      --List network members directly connected to this building
      if not clicked then
         printout("List directly connected network members for this " .. localising.get(ent,pindex),pindex)
      else
         local result = ""
      if nwr ~= nil then
         if nwg ~= nil then
            result = result .. "Red network: "
         end
         result = result .. circuit_network_neighbors_info(pindex, ent, defines.wire_type.red)
      end
      if nwg ~= nil then
         if nwr ~= nil then
            result = result .. "Green network: "
         end
         result = result .. circuit_network_neighbors_info(pindex, ent, defines.wire_type.green)
      end
      if result == "" then
         result = "Error: No network"
      end
      printout(result,pindex)
      end
   end
   --Rest of the menu depends on ent type 
   if ent.type == "electric-pole" then
      --Menu for electric poles
      if index > 3 then
         --(inventory edge: play sound and set index and call this menu again)
         p.play_sound{path = "inventory-edge"}
         players[pindex].circuit_network_menu.index = 3
         circuit_network_menu(pindex, ent, players[pindex].circuit_network_menu.index, false, false)
      end
      return
   else
      --Menu for other entities
      local control = ent.get_control_behavior()
      if control == nil then
         printout("No circuit network interface for this entity" , pindex)
         return
      end
      local control_has_no_circuit_conditions = ent.type == "container" or ent.type == "logistic-container" or ent.type == "storage-tank" or ent.type == "rail-chain-signal" or ent.type == "accumulator" or ent.type == "roboport"
      local circuit_cond = nil 
      local read_mode = get_circuit_read_mode_name(ent)
      local op_mode, uses_condition = get_circuit_operation_mode_name(ent)
      if control_has_no_circuit_conditions == false then 
         circuit_cond = control.circuit_condition
      end
      if index == 4 then
         --Read machine behavior summary
         if not clicked then
            printout("Read machine circuit behavior summary",pindex)
         else
            local result = ""
            result = result .. "Reading mode: " .. read_mode .. ", "
            result = result .. "Operation mode: " .. op_mode .. ", "
            if uses_condition == true then
               result = result .. read_circuit_condition(ent, true)
            end
            printout(result,pindex)
         end
      elseif index == 5 then
         --Toggle machine reading mode
         if not clicked then
            printout("Toggle reading mode: " .. read_mode,pindex)
         else
            local result, changed = toggle_circuit_read_mode(ent)
            printout(result,pindex)
            p.play_sound{path = "Inventory-Move"}
            if changed == false then
                p.play_sound{path = "inventory-edge"}
            end
         end
      elseif index == 6 then
         --Toggle machine control mode
         if not clicked then
            printout("Toggle operation mode: " .. op_mode,pindex)
         else
            local result, changed = toggle_circuit_operation_mode(ent)
            printout(result,pindex)
            p.play_sound{path = "Inventory-Move"}
            if changed == false then
                p.play_sound{path = "inventory-edge"}
            end
         end
      elseif index == 7 then
         --Toggle enabled condition comparing rule
         if not clicked then
            printout("Toggle enabled condition comparing rule ",pindex)
         else
            local result = "Not using a condition"
            if uses_condition == true then 
               result = toggle_condition_comparator(ent, pindex, true)
            end
            printout(result,pindex)
            p.play_sound{path = "Inventory-Move"}
         end
      elseif index == 8 then
         --Set enabled condition first signal
         if not clicked then
            printout("Set enabled condition first signal from the signal selector",pindex)
         else
            local result = "Not using a condition"
            if uses_condition == true then 
               result = "toggle"--****
            end
            printout(result,pindex)
            p.play_sound{path = "Inventory-Move"}
         end
      elseif index == 9 then
         --Set enabled condition second signal
         if not clicked then
            printout("Set enabled condition second signal from the signal selector",pindex)
         else
            local result = "Not using a condition"
            if uses_condition == true then 
               result = "toggle"--****
            end
            printout(result,pindex)
            p.play_sound{path = "Inventory-Move"}
         end
      elseif index == 10 then
         --Set enabled condition second signal as a constant number
         if not clicked then
            printout("Set enabled condition second signal as a constant number",pindex)
         else
            local result = "Not using a condition"
            if uses_condition == true then 
               result = "toggle"--****
            end
            printout(result,pindex)
            p.play_sound{path = "Inventory-Move"}
         end
      end
      return
   end
end
CIRCUIT_NETWORK_MENU_LENGTH = 10

function circuit_network_menu_open(pindex, ent)
   if players[pindex].vanilla_mode then
      return 
   end
   --Set the player menu tracker to this menu
   players[pindex].menu = "circuit_network_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Set the menu line counter to 0
   players[pindex].circuit_network_menu = {
      index = 0
      }
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   local cn_menu = players[pindex].circuit_network_menu
   circuit_network_menu(pindex, ent, cn_menu.index, false)
end

function circuit_network_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].circuit_network_menu.index = 0
   
   --play sound
   if not mute then
      game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}
   end
   
   --Close GUIs
   if game.get_player(pindex).gui.screen["signal-name-enter"] ~= nil then 
      game.get_player(pindex).gui.screen["signal-name-enter"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then
      game.get_player(pindex).opened = nil
   end
end

--Reads the total list of the circuit network neighbors of this entity. Gives details.
function circuit_network_neighbors_info(pindex, ent, wire_type) --****todo
   local color = nil
   if wire_type == defines.wire_type.red then
      color = "red"
   elseif wire_type == defines.wire_type.green then
      color = "green"
   else
      return "Error: invalid wire type"
   end
   local connected_circuit_count = ent.get_circuit_network(wire_type).connected_circuit_count
   local members_list = add_neighbors_to_circuit_network_member_list({},ent,color,1,2)
   if members_list == nil or #members_list == 0 then
      return "Error: No members"
   end
   local result = "Connected to "
   for i, member in ipairs(members_list) do
      if member.unit_number ~= ent.unit_number then
         result = result .. localising.get(member,pindex) .. " at " .. math.ceil(util.distance(member.position,ent.position)) .. " " .. direction_lookup(get_direction_of_that_from_this(member.position,ent.position)) .. ", "
      end
   end
   return result 
end 

--Reads the total list of the circuit network neighbors of this entity, and then their neighbors, and then their neighbors recursively.
function circuit_network_members_info(pindex, ent, wire_type) --****todo
   local color = nil
   if wire_type == defines.wire_type.red then
      color = "red"
   elseif wire_type == defines.wire_type.green then
      color = "green"
   else
      return "Error: invalid wire type"
   end
   local connected_circuit_count = ent.get_circuit_network(wire_type).connected_circuit_count
   local members_list = add_neighbors_to_circuit_network_member_list({},ent,color,1,10)
   if members_list == nil or #members_list == 0 then
      return "Error: No members"
   end
   local pole_counter = 0
   local ent_counter = 0
   local result = "Total of " .. connected_circuit_count .. " members, including "
   for i, member in ipairs(members_list) do
      if member.type == "electric-pole" then
         pole_counter = pole_counter + 1
      else
         ent_counter = ent_counter + 1
         result = result .. localising.get(member,pindex) .. ", "
      end
   end
   if ent_counter > 0 then
      result = result .. " and "
   end
   result = result .. pole_counter .. " electric poles, "
   return result 
end 

--Recursively checks circuit neighbors of the ent_in and adds them to the list of members
function add_neighbors_to_circuit_network_member_list(list_in,ent_in,color_in,iteration_in, iteration_limit)
   local list = list_in or {}
   local ent = ent_in
   local color = color_in or "red"
   local iteration = iteration_in or 1
   
   --Stop after iteration_limit to prevent UPS drain
   if iteration > iteration_limit then
      return list
   end
   
   --Add this ent to the list if not already
   if ent == nil or ent.valid == false then
      return list
   end
   local num = ent.unit_number
   local exists = false
   for i, list_ent in ipairs(list) do
      if list_ent.unit_number == num then
         exists = true
         --This ent was counted before already, so stop immediately
         return list
      end
   end
   if exists == false then
      table.insert(list,ent)
   end
   
   --Get all circuit neighbors and run again
   iteration = iteration + 1
   local neighbors = ent.circuit_connected_entities[color]
   if neighbors == nil or #neighbors == 0 then
      return list
   end
   for i, neighbor_ent in ipairs(neighbors) do
      add_neighbors_to_circuit_network_member_list(list,neighbor_ent,color,iteration,iteration_limit)
   end
   return list
end

--Lists first 10 signals in a circuit network
function circuit_network_signals_info(pindex, nw) --****todo
   local signals = nw.signals 
   local result = ""
   local total_signal_count = 0
   if signals == nil then
      result = "No signals at the moment"
      return result
   end
   --Loop through the list
   for i, sig in ipairs(signals) do 
      if total_signal_count >= 10 and #signals > 10 then
         result = result .. " and " .. (#signals - total_signal_count) .. " other signals "
         break
      end
      total_signal_count = total_signal_count + 1
      local sig_name = sig.signal.name
      local sig_type = sig.signal.type
      local sig_count = sig.count
      local sig_local_name = sig_name
      if sig_type == "item" then
         sig_local_name = localising.get(game.item_prototypes[sig_name],pindex)
      elseif sig_type == "fluid" then
         sig_local_name = localising.get(game.fluid_prototypes[sig_name],pindex)
      elseif sig_type == "virtual" then      
         sig_local_name = localising.get(game.virtual_signal_prototypes[sig_name],pindex)
      end
      result = result .. sig_local_name .. " times " .. sig_count .. ", "
   end
   return result
end 

function build_signal_selector(pindex)
   local item_group_names = {}
   local groups = game.item_group_prototypes
   for i, group in ipairs(groups) do 
      table.insert(item_group_names,group.name)
   end
   players[pindex].signal_selector = {
      signal_index = 1, 
      group_index = 1, 
      group_names = item_group_names, 
      signals = {}
   }
   --Populate signal groups 
   for i, group in ipairs(item_group_names) do 
      players[pindex].signal_selector.signals[group] = {}
      if group == "fluids" then
         players[pindex].signal_selector.signals[group] = game.fluid_prototypes
      elseif group == "signals" then
         players[pindex].signal_selector.signals[group] = game.virtual_signal_prototypes
      else
         for j, item in ipairs(game.item_prototypes) do 
            if item.group == group then
               table.insert(players[pindex].signal_selector.signals[group],item)
            end
         end
      end
   end
end

function get_selected_signal_with_type(pindex)
   if players[pindex].signal_selector == nil then
      build_signal_selector(pindex)
   end
   local group_index = players[pindex].signal_selector.group_index
   local signal_index = players[pindex].signal_selector.signal_index
   local group_name = players[pindex].signal_selector.group_names[group_index]
   local signal = players[pindex].signal_selector.signals[group_name][signal_index]
   local signal_type = "item"
   if group_name == "fluids" then
      signal_type = "fluid"
   elseif group_name == "signals" then
      signal_type = "virtual"
   end
   return signal, signal_type
end

function read_selected_signal_slot(pindex, start_phrase_in)
   local start_phrase = start_phrase_in or ""
   local prototype, signal_type = get_selected_signal_with_type(pindex)
   local sig_name = localising.get(prototype,pindex)
   local result = start_phrase .. sig_name .. " " .. signal_type
   printout(result,pindex)
end

function signal_selector_group_up(pindex)
   if players[pindex].signal_selector == nil then
      build_signal_selector(pindex)
   end
   game.get_player(pindex).play_sound{path = "Inventory-Move"}
   local jumps = 1
   if players[pindex].signal_selector.group_index <= 1 then
      players[pindex].signal_selector.group_index = #players[pindex].signal_selector.group_names
   else
      players[pindex].signal_selector.group_index = players[pindex].signal_selector.group_index - 1
   end
   
   local group_index = players[pindex].signal_selector.group_index 
   local group_name = players[pindex].signal_selector.group_names[group_index]
   local group = players[pindex].signal_selector.signals[group_name]
   
   --Go further up if this group is empty
   while (group == nil or #group == 0) and jumps < 10 do 
      jumps = jumps + 1
      if players[pindex].signal_selector.group_index <= 1 then
         players[pindex].signal_selector.group_index = #players[pindex].signal_selector.group_names
      else
         players[pindex].signal_selector.group_index = players[pindex].signal_selector.group_index - 1
      end
      group_index = players[pindex].signal_selector.group_index 
      group_name = players[pindex].signal_selector.group_names[group_index]
      group = players[pindex].signal_selector.signals[group_name]
   end
   --Reset signal level
   players[pindex].signal_selector.signal_index = 1
   return jumps
end

function signal_selector_group_down(pindex)
   if players[pindex].signal_selector == nil then
      build_signal_selector(pindex)
   end
   game.get_player(pindex).play_sound{path = "Inventory-Move"}
   local jumps = 1
   if players[pindex].signal_selector.group_index <= #players[pindex].signal_selector.group_names then
      players[pindex].signal_selector.group_index = players[pindex].signal_selector.group_index + 1
   else
      players[pindex].signal_selector.group_index = 1
   end
   
   local group_index = players[pindex].signal_selector.group_index 
   local group_name = players[pindex].signal_selector.group_names[group_index]
   local group = players[pindex].signal_selector.signals[group_name]
   
   --Go further up if this group is empty
   while (group == nil or #group == 0) and jumps < 10 do 
      jumps = jumps + 1
      if players[pindex].signal_selector.group_index <= #players[pindex].signal_selector.group_names then
         players[pindex].signal_selector.group_index = players[pindex].signal_selector.group_index + 1
      else
         players[pindex].signal_selector.group_index = 1
      end
      group_index = players[pindex].signal_selector.group_index 
      group_name = players[pindex].signal_selector.group_names[group_index]
      group = players[pindex].signal_selector.signals[group_name]
   end
   --Reset signal level
   players[pindex].signal_selector.signal_index = 1
   return jumps
end

function signal_selector_signal_next(pindex)
   local group_index = players[pindex].signal_selector.group_index
   local group_name = players[pindex].signal_selector.group_names[group_index]
   local group = players[pindex].signal_selector.signals[group_name]
   
   if players[pindex].signal_selector.signal_index <= #group then
      players[pindex].signal_selector.signal_index = players[pindex].signal_selector.signal_index + 1
   else
      players[pindex].signal_selector.signal_index = 1
   end
end

function signal_selector_signal_prev(pindex)
   local group_index = players[pindex].signal_selector.group_index
   local group_name = players[pindex].signal_selector.group_names[group_index]
   local group = players[pindex].signal_selector.signals[group_name]
   
   if players[pindex].signal_selector.signal_index > 1 then
      players[pindex].signal_selector.signal_index = players[pindex].signal_selector.signal_index - 1
   else
      players[pindex].signal_selector.signal_index = #group 
   end
end
