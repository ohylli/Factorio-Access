--Here: Functions relating to circuit networks, virtual signals, wiring and unwiring buildings, and the such.
--Does not include event handlers directly, but can have functions called by them.


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
            if network_found == nil or network_found.valid == false then
               network_found = "nil"
            end
            result = " Connected " .. localising.get(target_ent,pindex) .. " to electric network ID " .. network_found 
         else
            result = " Disconnected " .. wire_name 
         end
      end
      p.print(result)--***
      printout(result, pindex)
   else
      p.play_sound{path = "utility/cannot_build"}
   end
end

function constant_combinator_signals_info(ent)
   --***
end

function add_hand_to_constant_combinator_signals(ent, pindex)
   --***
end

function remove_last_constant_combinator_signal(ent)
   --***
end


--[[ Blueprint menu options summary
   0. "<BUILDING NAME> of Network <id_no> <color>." + instructions
   1. Read Mode: <None?>
   2. Control Mode: <Mode of operation>, Press LEFT BRACKET to toggle.
   3. Enable_mode: [Enabled when: <condition summary> ]  Read_mode:[Current output: <aignal name and count>]
   4. First signal: <SIGNAL>, Press LEFT BRACKET to load item in hand instead. You can also press ENTER and input a latin letter or digit to use as a signal by entering the character and then a forward slash character.
   5. Condition operator: <op>, Press LEFT BRACKET to toggle. 
   6. Second signal: <SIGNAL>, Press LEFT BRACKET to load item in hand instead OR press ENTER to type in a number instead. You can also input a latin letter or digit to use as a signal by entering the character and then a forward slash character.

   This menu opens when you press KEY when a building is selected.
]]
function circuit_network_menu(ent, menu_index, pindex, clicked, other_input)
   local index = menu_index
   
end