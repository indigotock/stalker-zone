-----------------------------------------------------------------------------------------------
-- Client Lua Script for Test
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"


-----------------------------------------------------------------------------------------------
-- Test Module Definition
-----------------------------------------------------------------------------------------------
local stalker_zone = {} 

local aDiffNames = {
  'Normal Mob',
  '',
  'Tough Mob',
  'Small Boss',
  'Big Boss',
  'Huge Boss'
}

function stalker_zone:new(o)
  local obj = o or {}
  setmetatable(obj, self)
  self.__index = self 

  obj.btools = {}
  obj.btools.util = Apollo.GetPackage('indigotock.btools.util').tPackage
  obj.btools.gui = {}
  obj.btools.gui.drop_button =
  Apollo.GetPackage('indigotock.btools.gui.drop_button').tPackage
  obj.btools.gui.number_ticker =
  Apollo.GetPackage('indigotock.btools.gui.number_ticker').tPackage
  obj.btools.gui.search_list =
  Apollo.GetPackage('indigotock.btools.gui.search_list').tPackage
  obj.btools.gui.slider =
  Apollo.GetPackage('indigotock.btools.gui.slider').tPackage
  obj.btools.gui.colour_picker =
  Apollo.GetPackage('indigotock.btools.gui.colour_picker').tPackage


  self.tSettings = {}
  self.tSettings.nAngle = 140
  self.tSettings.bShowFacing=false
  self.tSettings.sZoneColour = 'ff4386DE'
  self.tSettings.sFacingColour = 'ffDE9B43'
  self.tSettings.nThickness = 4
  self.tSettings.bOnlyCombat = false
  self.tSettings.aUseLAS = {true,true,true,true}
  self.tSettings.aDifficultyLengths = {5, 5, 7, 7, 10, 15}
  return obj
end

function stalker_zone:build_window()
  if self.cConfigWindow:FindChild('thickness_slider'):FindChild('slider') then
    self.cConfigWindow:FindChild('thickness_slider'):DestroyChildren()
  end
  if self.cConfigWindow:FindChild('angle_slider'):FindChild('slider') then
    self.cConfigWindow:FindChild('angle_slider'):DestroyChildren()
  end
  if self.cConfigWindow:FindChild('line_colour_picker'):FindChild('red_slider') then
    self.cConfigWindow:FindChild('line_colour_picker'):DestroyChildren()
  end
  if self.cConfigWindow:FindChild('facing_colour_picker'):FindChild('red_slider') then
    self.cConfigWindow:FindChild('facing_colour_picker'):DestroyChildren()
  end
  for diff = 1, 6 do
    if self.cConfigWindow:FindChild('diff_slider_'..diff) and self.cConfigWindow:FindChild('diff_slider_'..diff):FindChild('slider') then
      self.cConfigWindow:FindChild('diff_slider_'..diff):DestroyChildren()
    end
  end
  --self.cConfigWindow:FindChild('List'):ArrangeChildrenVert()
  self.cConfigWindow:FindChild('button_facingline'):SetCheck(self.tSettings.bShowFacing)
  self.cConfigWindow:FindChild('button_onlycombat'):SetCheck(self.tSettings.bOnlyCombat)
  self.cConfigWindow:FindChild('button_las_1'):SetCheck(self.tSettings.aUseLAS[1])
  self.cConfigWindow:FindChild('button_las_2'):SetCheck(self.tSettings.aUseLAS[2])
  self.cConfigWindow:FindChild('button_las_3'):SetCheck(self.tSettings.aUseLAS[3])
  self.cConfigWindow:FindChild('button_las_4'):SetCheck(self.tSettings.aUseLAS[4])

  self.btools.gui.slider(self.cConfigWindow:FindChild('thickness_slider'), {sHeader='Line Thickness:', nMinValue = 1, nMaxValue = 10, nInitialValue = self.tSettings.nThickness,
    fChangeCallback = function(val) self.tSettings.nThickness = val self:recalculate_angle() end, fValueMod = function(val) return tostring(val)..'px' end})
  self.btools.gui.slider(self.cConfigWindow:FindChild('angle_slider'), {sHeader = 'Angle:', nMinValue = 90, nMaxValue = 140, nInitialValue = self.tSettings.nAngle,
    fChangeCallback = function(val) self.tSettings.nAngle = val self:recalculate_angle() end, fValueMod = function(val) return tostring(val)..'°' end})

  self.btools.gui.colour_picker(self.cConfigWindow:FindChild('line_colour_picker'), {
    fCallback = function(hex) self.tSettings.sZoneColour = hex end,
    nRedValue = tonumber(string.sub(self.tSettings.sZoneColour,3,4), 16),
    nGreenValue = tonumber(string.sub(self.tSettings.sZoneColour,5,6), 16),
    nBlueValue = tonumber(string.sub(self.tSettings.sZoneColour,7,8), 16)
    })

  self.btools.gui.colour_picker(self.cConfigWindow:FindChild('facing_colour_picker'), {
    fCallback = function(hex) self.tSettings.sFacingColour = hex end,
    nRedValue = tonumber(string.sub(self.tSettings.sFacingColour,3,4), 16),
    nGreenValue = tonumber(string.sub(self.tSettings.sFacingColour,5,6), 16),
    nBlueValue = tonumber(string.sub(self.tSettings.sFacingColour,7,8), 16)
    })


  for diff = 1, 6 do
    if diff ~= 2 then
      self.btools.gui.slider(self.cConfigWindow:FindChild('diff_slider_'..diff), {
        nMinValue = 3, nMaxValue=40, nInitialValue = self.tSettings.aDifficultyLengths[diff],
        fChangeCallback = function(val) self.tSettings.aDifficultyLengths[diff] = val end,
        sHeader = aDiffNames[diff]
        })
    end
  end
  --self.cConfigWindow:FindChild('slider_angle'):SetValue(self.tSettings.nAngle)
  --self.cConfigWindow:FindChild('slider_thickness'):SetValue(self.tSettings.nThickness)
end

function stalker_zone:recalculate_angle()
  self.nLeftAngle = 180 - (self.tSettings.nAngle/2)
  self.nRightAngle = 180 + (self.tSettings.nAngle/2)
end

function stalker_zone:init()
  Apollo.RegisterAddon(self,true,'Stalker Zone',{})
  Apollo.RegisterEventHandler('NextFrame','draw_zone',self)
end

function stalker_zone:OnLoad()
  local xmlDoc = XmlDoc.CreateFromFile('stalker-zone.xml')
  -- load our form file
  self.cPanel = Apollo.LoadForm(
    xmlDoc,
    'draw_panel',
    'InWorldHudStratum',
    self)
  self.cConfigWindow= Apollo.LoadForm(
    xmlDoc,
    'config_window',
    nil,
    self)
  Apollo.RegisterSlashCommand("sz","invoke",self)
  self:recalculate_angle()
  self.cConfigWindow:Show(true)
  self:build_window()
end

function stalker_zone:OnConfigure()
  self:invoke()
end

function stalker_zone:invoke()
  self.cConfigWindow:Show(true)
end

function stalker_zone:draw_zone()
  self.cPanel:DestroyAllPixies()
  if not GameLib.GetPlayerUnit() then return end
  local targ = GameLib.GetPlayerUnit():GetTarget()
  -- If no target
  if not targ then return end
  -- If not a stalker
  --if GameLib.GetPlayerUnit():GetClassId() ~= GameLib.CodeEnumClass.Stalker then return end

  if self.tSettings.bOnlyCombat then if not GameLib.GetPlayerUnit():IsInCombat() then return end end
  

  if not self.tSettings.aUseLAS[AbilityBook.GetCurrentSpec()] then return end

  -- if not neutral or  hostile. need to add cusotmisation options
  if GameLib.GetPlayerUnit():GetDispositionTo(GameLib.GetPlayerUnit():GetTarget()) ==3 or GameLib.GetPlayerUnit():GetDispositionTo(GameLib.GetPlayerUnit():GetTarget()) == 2 then return end

  local player_pos = GameLib.GetPlayerUnit():GetPosition()
  local player_pos_vector = Vector3.New(player_pos.x,player_pos.y,player_pos.z)

  local targ_face = targ:GetFacing()
  local targ_angle = math.atan2(targ_face.x, targ_face.z)
  local left_point = targ_angle + math.rad(self.nLeftAngle)
  local right_point = targ_angle + math.rad(self.nRightAngle)

  local targ_screen_pos = GameLib.GetUnitScreenPosition(targ)
  local targ_pos = targ:GetPosition()
  local targ_pos_vector = Vector3.New(targ_pos.x,targ_pos.y,targ_pos.z)

  local diff = targ:GetDifficulty() or 1
  local line_len = self.tSettings.aDifficultyLengths[diff] or self.tSettings.aDifficultyLengths[1]
  if  self.tSettings.bShowFacing then 
    local face_vector = Vector3.New(targ_pos_vector.x+line_len*math.sin(targ_angle), targ_pos_vector.y, targ_pos_vector.z+line_len*math.cos(targ_angle))
  --local arrow_left_vector = Vector3.New(targ_pos_vector.x+6.5*math.sin(targ_angle-math.rad(5)), targ_pos_vector.y, targ_pos_vector.z+6.5*math.cos(targ_angle-math.rad(5)))
  --local arrow_right_vector = Vector3.New(targ_pos_vector.x+6.5*math.sin(targ_angle+math.rad(5)), targ_pos_vector.y, targ_pos_vector.z+6.5*math.cos(targ_angle+math.rad(5)))
  self:draw_line(targ_pos_vector, face_vector,self.tSettings.sFacingColour)
end

local left_vector = Vector3.New(targ_pos_vector.x+line_len*math.sin(left_point), targ_pos_vector.y, targ_pos_vector.z+line_len*math.cos(left_point))

self:draw_line(left_vector, targ_pos_vector,self.tSettings.sZoneColour)

local right_vector = Vector3.New(targ_pos_vector.x+line_len*math.sin(right_point), targ_pos_vector.y, targ_pos_vector.z+line_len*math.cos(right_point))
self:draw_line(right_vector, targ_pos_vector,self.tSettings.sZoneColour)

 -- self:draw_line(face_vector,arrow_right_vector,'ffDE9B43')
 -- self:draw_line(face_vector,arrow_left_vector,'ffDE9B43')


  -- local last_vec = left_vector

  -- local angle_diff = math.rad(self.tSettings.nAngle)

  -- local arc_start = targ_angle+(math.pi-angle_diff/2)
  -- local arc_end = (targ_angle+(math.pi-angle_diff/2))+angle_diff

  -- for i = arc_start, arc_end, (arc_end-arc_start)/self.nSegments do
  --   local new_vec = Vector3.New(targ_pos_vector.x + (7 * math.sin(i)), targ_pos_vector.y, targ_pos_vector.z + (7 * math.cos(i)))
  --   self:draw_line(last_vec,new_vec)
  --   last_vec = new_vec
  -- end


end

function stalker_zone:OnSave(type)
  if type ~= GameLib.CodeEnumAddonSaveLevel.Account then return end
  return self.tSettings
end

function stalker_zone:OnRestore(type,table)
  for k,v in pairs(table) do
    self.tSettings[k]=v
  end
  self:build_window()
end

function stalker_zone:draw_line(vec1, vec2, col)
  local start_point = GameLib.WorldLocToScreenPoint(vec1)
  local end_point = GameLib.WorldLocToScreenPoint(vec2)
  self.cPanel:AddPixie( {
    bLine = true, fWidth = self.tSettings.nThickness*1.5, cr = 'ff000000',
    loc = { fPoints = { 0, 0, 0, 0 }, nOffsets = { start_point.x, start_point.y, end_point.x, end_point.y } }
    })
  self.cPanel:AddPixie( {
    bLine = true, fWidth = self.tSettings.nThickness, cr = col or 'ffff00ff',
    loc = { fPoints = { 0, 0, 0, 0 }, nOffsets = { start_point.x, start_point.y, end_point.x, end_point.y } }
    })
end

function stalker_zone:event_change_angle(handler,control,value)
  self.tSettings.nAngle = value or 100
  self.nSegments = value or 100
  self:recalculate_angle()

  self:build_window()
end

function stalker_zone:event_change_thickness(handler,control,value)
  self.tSettings.nThickness = value or 100

  self:build_window()
end

function stalker_zone:event_toggle_onlycombat(handler,control)
  self.tSettings.bOnlyCombat = control:IsChecked() or false

  self:build_window()
end

function stalker_zone:event_toggle_facing(handler,control)
  self.tSettings.bShowFacing = control:IsChecked() or false

  self:build_window()
end

function stalker_zone:event_close_config()
  self.cConfigWindow:Show(false)
end

function stalker_zone:set_las(handler,control)
  local num = tonumber(control:GetName():sub(-1))
  local on = control:IsChecked()
  self.tSettings.aUseLAS[num] = on
end

stalker_zone:new():init()
