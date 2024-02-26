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
   local sig_name = signal.name
   local sig_type = signal.type
   if sig_name == nil then
      sig_name = "nil"
   end
   if sig_type == nil then
      sig_type = "nil"
   end
   local result = (sig_type .. " " .. sig_name) 
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
   local result = " with signals " 
   if valid_signals_count == 0 then
      result = " with no signals "
   else
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
            result = "Read held items" 
         elseif control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.pulse then
            result = "Pulse passing items" 
         end
      end
   elseif ent.type == "transport-belt" then
      if control.read_contents == true then
         if control.read_contents_mode == dcb.transport_belt.content_read_mode.hold then
            result = "Read held items" 
         elseif control.read_contents_mode == dcb.transport_belt.content_read_mode.pulse then
            result = "Pulse passing items"
         end
      end
   elseif ent.type == "container" or ent.type == "logistic-container" or ent.type == "storage-tank" then
      result = "Read contents"
   elseif ent.type == "gate" then
      result = "Read player presence in virtual signal G"
   elseif ent.type == "rail-signal" or ent.type == "rail-chain-signal" then
      result = "Read virtual color signals for rail signal states"
   elseif ent.type == "train-stop" then
      result = "Read train ID in virtual signal T and en route train count in virtual signal C" 
   elseif ent.type == "accumulator" then
      result = "Read charge percentage in virtual signal A"
   elseif ent.type == "roboport" then
      result = "Read something "--todo explain other read modes***
   elseif ent.type == "mining-drill" then
      result = "Read something "--todo explain other read modes***
   elseif ent.type == "pumpjack" then
      result = "Read something "--todo explain other read modes***
   end
   return result
end

function toggle_circuit_read_mode(ent)
   local result = "No change"
   local control = ent.get_control_behavior()
   if ent.type == "inserter" then
      if control.circuit_read_hand_contents == false then
         control.circuit_read_hand_contents = true
         control.circuit_hand_read_mode = dcb.inserter.hand_read_mode.hold
         result = "Read held items" 
      elseif control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.hold then
         control.circuit_read_hand_contents = true
         control.circuit_hand_read_mode = dcb.inserter.hand_read_mode.pulse
         result = "Pulse passing items"
      else --if control.circuit_hand_read_mode == dcb.inserter.hand_read_mode.pulse then
         control.circuit_read_hand_contents = false
         result = "None"
      end
   elseif ent.type == "transport-belt" then 
      if control.read_contents == false then
         control.read_contents = true
         control.read_contents_mode = dcb.transport_belt.content_read_mode.hold 
         result = "Read held items" 
      elseif control.read_contents_mode == dcb.transport_belt.content_read_mode.hold then
         control.read_contents = true
         control.read_contents_mode = dcb.transport_belt.content_read_mode.pulse
         result = "Pulse passing items"
      else --if control.read_contents_mode == dcb.transport_belt.content_read_mode.pulse then
         control.read_contents = false
         result = "None"
      end
   else
      result = "No change" --laterdo** allow toggling some other read modes
   end
   return result
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
   local control = ent.get_control_behavior()
   if ent.type == "inserter" then 
      if control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.none then
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.enable_disable
         result = "Enable with condition"
      elseif control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.enable_disable then
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.read_hand_contents
         result = "Only read hand contents"
      elseif control.circuit_mode_of_operation == dcb.inserter.circuit_mode_of_operation.read_hand_contents then
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.none
         result = "None"
      else
         control.circuit_mode_of_operation = dcb.inserter.circuit_mode_of_operation.none
         result = "None"
      end
   elseif ent.type == "transport-belt" then 
      if control.enable_disable == true then
         control.enable_disable = false
         result = "None"
      else
         control.enable_disable = true
         result = "Enable with condition"
      end
   elseif ent.name == "logistic-requester-chest" then
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
      if control.circuit_condition ~= nil or control.disabled == true then--**laterdo
         result = "Enable with condition"
      else
         result = "None"
      end
   elseif ent.type == "pump" then
      if control.circuit_condition ~= nil or control.disabled == true then--**laterdo
         result = "Enable with condition"
      else
         result = "None"
      end
   else
      result = "None"
   end
   return result
end

function read_circuit_condition(ent)
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
   local result = first_signal_name .. " " .. comparator .. " " .. second_signal_name
   return result 
end

function toggle_condition_comparator(circuit_condition, pindex)
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
   printout(comparator, pindex)
   return 
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
   
   0) Menu info: "Electric Poles of Circuit Network <id_no> <color>, with # members." + instructions
   1) List all active signals of this network
   2) List all members of this network
   3) List buildings connected to this electric pole
   4) (Inventory edge, call 3)
   
   0) Menu info: "Electric Poles of Circuit Network <id_no> <color>, with # members." + instructions
   1) List all active signals of the network
   2) Read machine behavior summary: "Reading none and enabled when X < Y"
   3) Toggle machine reading mode: None / Read held contents / Pulse passing contents
   4) Toggle machine control mode: None / Enabled condition
   5) Toggle enabled condition comparing rule: greater than / less than / equal to / not equal to
   6) Set enabled condition first signal: Use the signal selector
   7) Set enabled condition second signal: Press LB to use the signal selector or press ENTER to type in a constant

   This menu opens when you press KEY when a building menu is open.
]]
function circuit_network_menu(pindex, ent, menu_index, clicked, other_input)
   local index = menu_index
   local control = ent.get_control_behavior()
   if control == nil then
      printout("No circuit network interface for this entity" , pindex)
      return
   end
   local circuit_cond = control.circuit_condition
   
   if ent.type == "electric-pole" then
      if index == 0 then
         --Menu info
      elseif index == 1 then
         --List all active signals of this network
      elseif index == 2 then
         --List all members of this network
      elseif index == 3 then
         --List buildings connected to this electric pole
      elseif index > 3 then
         --(inventory edge: play sound and set index and call this menu again)
      end
      return
   else
      if index == 0 then
         --Menu info
      elseif index == 1 then
         --List all active signals of this network
      elseif index == 2 then
         --Read machine behavior summary
      elseif index == 3 then
         --Toggle machine reading mode
      elseif index == 4 then
         --Toggle machine control mode
      elseif index == 5 then
         --Toggle enabled condition comparing rule
      elseif index == 6 then
         --Set enabled condition first signal
      elseif index == 7 then
         --Set enabled condition second signal
      end
      return
   end
end
CIRCUIT_NETWORK_MENU_LENGTH = 7

function circuit_network_menu_open(pindex)
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
   circuit_network_menu(pindex, nil, cn_menu.index, false)
end

function circuit_network_close(pindex, mute_in)
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

function circuit_network_menu_up(pindex)
   players[pindex].circuit_network_menu.index = players[pindex].circuit_network_menu.index - 1
   if players[pindex].circuit_network_menu.index < 0 then
      players[pindex].circuit_network_menu.index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   local cn_menu = players[pindex].circuit_network_menu
   circuit_network_menu(pindex, nil, cn_menu.index, false)
end

function circuit_network_menu_down(pindex)
   players[pindex].circuit_network_menu.index = players[pindex].circuit_network_menu.index + 1
   if players[pindex].circuit_network_menu.index > CIRCUIT_NETWORK_MENU_LENGTH then
      players[pindex].circuit_network_menu.index = CIRCUIT_NETWORK_MENU_LENGTH
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   local cn_menu = players[pindex].circuit_network_menu
   circuit_network_menu(pindex, nil, cn_menu.index, false)
end
