For use with Dolphin Lua Core 4.3, by MikeXander: https://github.com/MikeXander/Dolphin-Lua-Core/releases/tag/v4.3
Dolphin Memory Engine (DME): https://github.com/aldelaro5/dolphin-memory-engine/releases/tag/v1.2.4

--- Intro ---

These are a set of lua scripts for TASing New Super Mario Bros Wii. They provide important tools which are not normally available with Dolphin, such as displaying important memory values on-screen, exporting/importing inputs (useful for editing past work or testing routes), and more controlled mashing (for level entry ease-of-use or penguin swimming). All scripts except for NSMBWii_Core.lua go in your dolphin directory -> sys -> scripts. To execute a script in Dolphin, select the Tools menu -> Execute Script. This will open a window to select the script you want to use. After starting a script, you must frame advance once or let dolphin play the emulation in order for it to actually start.

--- Script Description ---

**NSMBWii_Core.lua**

This script goes in your main dolphin directory (the same as Dolphin.exe). This script keeps track of the game's inner-workings that we care about, and most other scripts use this while they are running.

**Data.lua**

This script displays all of the game's info that you would want to see while TASing. It has precise IGT, Mario's speed/position and other stats, and the object list. While ImportIL.lua or ExportIL.lua are running, it will also display useful statistics to show that those scripts are working properly. This script also has the option to display the A-cycle produced by SwimForMe.lua, but you must uncomment a few lines (as specified near the top of the file) in order to use this feature.
  
  Viewing the full object list:
  
  By default, the object list at the bottom of Data.lua displays mostly only physical objects (ignoring things like 'CAMERA' or 'YES_NO_WINDOW'), one object type per line, in the form 'ICEBALL x2'. If you would like to see the full object list with a memory addresses listed for each individual object, scroll down to the bottom of Data.lua and comment the line with 'core.object.list().compactObjList' and uncomment the line with 'core.object.list().fullObjList'. 
  
  Watching a specific object:
  
  One other, extremely useful tool is to watch a specific object type or see an objects speed and position. To do this, you first have to determine what the desired object's in-game object name is. Try looking at the compact object list in Data.lua to determine what this is, sometimes it will be something simple like 'EN_BOSS_IGGY' for Iggy, or something harder like 'INTERMITTENT' for sand geysers. At the top of NSMBWii_core.lua, there is a line 'local searchItem = ',KOOPA_FIRE,''. Replace 'KOOPA_FIRE' with whatever object you would like to watch. If you want to watch multiple objects, write them in this format: ',object1,object2,object3,'. Now, save the file, uncomment the line with 'core.object.list().itemSearchList' at the bottom of Data.lua, then cancel and restart Data.lua in Dolphin, and then your object will be displayed there!

**ImportIL.lua and ExportIL.lua**

These are the necessary scripts to import and use the Individial Level (IL) TAS files in this repository, or create your own. 
  
To import a TAS file: 

Copy the file you would like to import into your main Dolphin direcroy, and rename it to 'tas.txt'. Then, go to the specified level in-game, equip specified items, and enter the level. At any time while the level banner is displayed, start 'ImportIL.lua', and the TAS will play back once the level loads. It is recommended to pause the game on the level banner while you start the script, but is not required. If you are trying to understand/improve a level's TAS, it is strongly reccomended to use Data.lua to watch memory values during this process. 
  
  While importing inputs, loads are ignored, This comes at the cost that if you try to load a savestate set in room 1 while already in room 2, etc, the tas will inevitably desync. If you want to rewind like that, you can start recording input before starting the script, set savestates while the script is replaying, then once you reach the end set one final savestate, turn on read-only mode, and load earlier savestates to rewatch that part of the tas again.
  
  When the level loads, you will get a message at the top of the screen detailing whether controller settings and RNG are good. If RNG is a problem in the level, the message will tell you what the RNG should be and you can use DME to resync it.

To create your own TAS file:

This is useful if you want to share your own IL inputs as an improvement to what is currently done, or for detailed feedback. To use, simply start ExportIL.lua at any point during the level banner, then let your TAS play out. Cancel the script after reaching the end of the TAS. It is considerate to cancel the script very soon after the flag/pipe/whenever the last important input is, but it functionally doesn't matter if it goes longer.

**Alternate.lua**

This script mashes A/2 on alternating frames. Dolphin 5.0's integrated turbo input isn't accurate at all, so this is a better bet when you need accuracy. It's useful for dismissing the level banner on the optimal time automatically, and Data.lua will display what time the level banner got dismissed, so if you want clean inputs, you can more quickly figure out when the optimal frame to press A to dismiss the banner is. 

The script is also easily-customizable to press any button for a different amount of time, repeating on different intervals, or doing something different if you're pressing a different button. For a refference on how to format different button presses, look at ImportIL.lua.

**SwimForMe.lua**

This is a slightly altered version of Alternate.lua, made specifically for penguin swimming. On the frame before you want to press A, start the script, then it will start Pressing A once every 19 frames. If you need to shoot an ice ball underwater or delay swimming by a frame, or anything that changes when your next stroke occurs, you will need to cancel and restart the script in order to resync it. To see how long it has been since the last A-press, uncomment the associated lines in Data.lua, as listed in a comment near the top of Data.lua.
