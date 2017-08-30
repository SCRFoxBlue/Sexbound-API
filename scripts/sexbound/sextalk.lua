--- Sex Talk Module.
-- @module sextalk
sextalk = {}

require "/scripts/util.lua"

--- Initializes the sextalk module.
function sextalk.init()
  -- Handle request for current dialog
  message.setHandler("requestDialog", function()
    return sextalk.getCurrentDialog()
  end)
  
  -- Load the dialog config file
  self.dialog = root.assetJson(self.sexboundConfig.sextalk.dialog)

  self.currentDialog = "*Silent*"
  
  local animationState = animator.animationState("sex")
  
  -- Select initial dialog
  sextalk.selectNext(animationState)
end

--- Returns the currently selected dialog.
--@return string: current dialog text
function sextalk.getCurrentDialog()
  return self.currentDialog
end

--- Returns the current method used to select dialog.
--@return string: method name
function sextalk.getMethod()
  return self.sexboundConfig.sextalk.method
end

--- Returns the current mode used to select dialog.
--@return string: mode name
function sextalk.getMode()
  return self.sexboundConfig.sextalk.mode
end

--- Private: Selects and set a new random dialog.
--@param table choices from dialog config
local function selectRandom(choices)
  if not sextalk.isEnabled() then return nil end

  local currentDialog = sextalk.getCurrentDialog()
  local selection = ""
  
  if not isEmpty(choices) then
    -- Try not to repeat the last dialog
    for i=1,5 do
      selection = util.randomChoice(choices)
      
      if (selection ~= currentDialog) then
        break
      end
    end
  else
    selection = "*Speechless*"
  end
  
  sextalk.setCurrentDialog(selection)
  
  return selection
end

--- Returns the current dialog.
--@param state The state to retrieve the dialog.
function sextalk.selectNext(state)
  if not sextalk.isEnabled() then return nil end
  
  local choices = {}
  
  if (self.dialog[state] ~= nil) then
    choices = self.dialog[state].default.default
  end
  
  local currentDialog = selectRandom( choices )
  
  return currentDialog
end

---Outputs the dialog via the entity's say function.
--@param state The state to retrieve the dialog.
function sextalk.sayNext(state)
  if not sextalk.isEnabled() then return nil end

  local currentDialog = sextalk.selectNext(state)
  
  local method = sextalk.getMethod()
  
  if (method == "chatbubblePortrait") then
    object.sayPortrait( currentDialog, portrait.getCurrentPortrait() )
  end
  
  if (method == "chatbubble") then
    object.say(currentDialog)
  end
end

--- Sets the currentDialog.
--@param newDialog String: Dialog text.
function sextalk.setCurrentDialog(newDialog)
  -- Set the previous dialog before setting a new dialog
  self.previousDialog = self.currentDialog

  self.currentDialog = newDialog
  
  return self.currentDialog
end

--- Returns the enabled status of the sex talk module.
-- @return boolean enabled
sextalk.isEnabled = function()
  return self.sexboundConfig.sextalk.enabled
end
