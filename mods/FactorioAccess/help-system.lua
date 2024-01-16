--Here is the help and tutorial menu

function help_menu(menu_index, pindex, clicked)
   local step = menu_index
   local part
   if step == 0 then
      if not clicked or clicked then
         printout("Menu line", pindex)
      end
   elseif step == 1 then
      if not clicked or clicked then
         printout("Menu line", pindex)
      end
   elseif step == 2 then
      if not clicked or clicked then
         printout("Menu line", pindex)
      end
   elseif step == 3 then
      if not clicked or clicked then
         printout("Menu line", pindex)
      end
   elseif step == 4 then
      if not clicked or clicked then
         printout("Menu line", pindex)
      end
   end
end
HELP_MENU_LENGTH = 10

