--Here is the help and tutorial menu

--The tutorial strings are fetched according to locale, with the main set of tutorial strings being im English ("en").
--Other locales are expected to have the same arrangement of tutorial steps.
function load_tutorial(pindex)
   local tutorial = players[pindex].tutorial 
   if tutorial == nil then 
      tutorial = {}
   end
   
   --Load tutorial header and detail strings
   tutorial.step_headers =  {} --2D array of localised strings
   tutorial.step_details =  {} --2D array of localised strings
   local CHAPTER_1_LENGTH = 0 --Lengths are constants depending on how we write the "en" strings.
   local CHAPTER_2_LENGTH = 0
   local CHAPTER_3_LENGTH = 0
   local CHAPTER_4_LENGTH = 0
   local CHAPTER_5_LENGTH = 0
   local CHAPTER_6_LENGTH = 0
   local CHAPTER_7_LENGTH = 0
   local CHAPTER_8_LENGTH = 0
   local CHAPTER_9_LENGTH = 0

   tutorial.chapter_lengths = {CHAPTER_1_LENGTH, CHAPTER_2_LENGTH, CHAPTER_3_LENGTH, CHAPTER_4_LENGTH, CHAPTER_5_LENGTH, CHAPTER_6_LENGTH, CHAPTER_7_LENGTH, CHAPTER_8_LENGTH, CHAPTER_9_LENGTH}
   
   local str_count = 0
   local err_count = 0
   for i = 1, #tutorial.chapter_lengths, 1, do --for every chapter
      local chapter_length = tutorial.chapter_lengths[i]   
      for j = 1, chapter_length, 1 do --for every step
         local header_str_name = "tutorial-chapter-" .. i .. "-step-" .. j .. "-header"
         local header_localised_str = {header_str_name}--***maybe here it needs to call localising.get ?
         if header_localised_str ~= nil then
            table.insert(tutorial.step_headers[i],header_localised_str) --for each step
         else
            err_count = err_count + 1
            --game.print("error in preparing tutorial header string " .. i .. "-" .. j,{volume_modifier = 0})
         end
         
         local detail_str_name = "tutorial-chapter-" .. i .. "-step-" .. j .. "-detail"
         local detail_localised_str = {detail_str_name}--***maybe here it needs to call localising.get ?
         if detail_localised_str ~= nil then
            table.insert(tutorial.step_details[i],detail_localised_str) --for each step
         else
            err_count = err_count + 1
            --game.print("error in preparing tutorial detail string " .. i .. "-" .. j,{volume_modifier = 0})
         end
         
         str_count = str_count + 1
      end
   end
   if err_count > 0 then
      game.print(err_count .. " errors while preparing ".. str_count .. " tutorial strings",{volume_modifier = 0})
   end
   
   --Load other tutorial strings
   --todo*** chapter 0 string(s) 
   --todo*** check result strings 
   
   --Load other tutorial variables
   tutorial.chapter_index = 0
   tutorial.step_index = 1
   tutorial.rocket_fuel_provided = false

end

function tutorial_menu_open(pindex)--todo***

end

function tutorial_menu_close(pindex)--todo***

end

function tutorial_menu_up(pindex)
	local tutorial = players[pindex].tutorial
	tutorial.step_index = tutorial.step_index - 1
	--play_sound: inv move***
	if tutorial.step_index == 0 then
		tutorial.chapter_index = tutorial.chapter_index - 1
		if tutorial.chapter_index == -1 then
			tutorial.chapter_index = 0
			tutorial.step_index = 1
			--play_sound: end of list***
		elseif tutorial.chapter_index == 0
			tutorial.step_index = 1
		else
			tutorial.step_index = tutorial.chapter_lengths[tutorial.chapter_index]
		end
	end
end

function tutorial_menu_down(pindex)
	local tutorial = players[pindex].tutorial
	tutorial.step_index = tutorial.step_index + 1
	--play_sound: inv move***
	if tutorial.step_index > tutorial.chapter_lengths[tutorial.chapter_index] then
		tutorial.chapter_index = tutorial.chapter_index + 1
		if tutorial.chapter_index > #tutorial.chapter_lengths or tutorial.chapter_lengths[tutorial.chapter_index] == 0 then
			tutorial.chapter_index = tutorial.chapter_index - 1
			tutorial.step_index = tutorial.step_index - 1
			--play_sound: end of list***
		else
			tutorial.step_index = 1
		end
	end
end

function tutorial_menu_read_out_header(pindex)
	local tutorial = players[pindex].tutorial
	local i = tutorial.chapter_index
	local j = tutorial.step_index
	local str = tutorial.step_headers[i][j]
	printout(str,pindex)
end

function tutorial_menu_read_out_detail(pindex)
	local tutorial = players[pindex].tutorial
	local i = tutorial.chapter_index
	local j = tutorial.step_index
	local str = tutorial.step_details[i][j]
	printout(str,pindex)
end

--For most steps this reads the already-loaded strings
function tutorial_menu(pindex, reading_the_header, clicked)
	local tutorial = players[pindex].tutorial
	local chap = tutorial.chapter_index
	local step = tutorial.step_index
   local p = game.get_player(pindex)
	if chap == 0 and step == 1 then
		--Read out chapter 0 message
      --printout(tutorial.chapter_0_string,pindex)--***
	elseif chap == 0 and step == 3 then --Example
		--Do a specific action for this step, e.g. provide an item or run a check
      if clicked == false then
         if reading_the_header == true then
            tutorial_menu_read_out_header(pindex)--Check step header, e.g. "multiple furnaces check"
         else
            tutorial_menu_read_out_detail(pindex)--Check step detail, e.g. "click here to run a check for this step" 
         end
      else --if clicked == true then
         --Run the check and print the appropriate tutorial check result string
         local ents = p.surface.find_entities_filtered{position = p.position, radius = 100, name = "stone-furnace"}
         if #ents > 1 then --(more checks here)
            --printout(tutorial.check_passed,pindex) --e.g. "Check passed"
         elseif #ents == 1 then --(more checks here)
            --printout(tutorial.check_message_just_1_ent,pindex) --e.g. "Check issue, only 1 ent found"
         else
            --printout(tutorial.check_failed,pindex) --e.g. "Check failed"
         end
      end
	elseif chap > 0 and step > 0 then
		--All other steps: Just read the header/detail
		if reading_the_header == true then
			tutorial_menu_read_out_header(pindex)
		else
			tutorial_menu_read_out_detail(pindex)
		end
	else
		--printout(tutorial_error_string_1,pindex)--*** "Tutorial error occurred"
	end
end