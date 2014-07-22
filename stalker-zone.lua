-----------------------------------------------------------------------------------------------
-- Client Lua Script for Test
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"

-----------------------------------------------------------------------------------------------
-- Test Module Definition
-----------------------------------------------------------------------------------------------
local stalker_zone = {} 

local nAngle = 140

local nSegments = 10

local nLeftAngle = 180 - (nAngle/2)
local nRightAngle = 180 + (nAngle/2)

function stalker_zone:new(o)
  local obj = o or {}
  setmetatable(obj, self)
  self.__index = self 
  return obj
end

function stalker_zone:init()
  Apollo.RegisterAddon(self,false)
  Apollo.RegisterEventHandler('NextFrame','draw_zone',self)
end

function stalker_zone:OnLoad()
  -- load our form file
  self.cPanel = Apollo.LoadForm(
    XmlDoc.CreateFromFile('stalker-zone.xml'),
    'draw_panel',
    'InWorldHudStratum',
    self)
end

function stalker_zone:draw_zone()
  self.cPanel:DestroyAllPixies()
  local targ = GameLib.GetPlayerUnit():GetTarget()
  -- If no target
  if not targ then return end
  -- If not a stalker
  if GameLib.GetPlayerUnit():GetClassId() ~= GameLib.CodeEnumClass.Stalker then return end

  


  local targ_face = targ:GetFacing()
  local targ_angle = math.atan2(targ_face.x, targ_face.z)
  local left_point = targ_angle + math.rad(nLeftAngle)
  local right_point = targ_angle + math.rad(nRightAngle)

  local targ_screen_pos = GameLib.GetUnitScreenPosition(targ)
  local targ_pos = targ:GetPosition()
  local targ_pos_vector = Vector3.New(targ_pos.x,targ_pos.y,targ_pos.z)

  local left_vector = Vector3.New(targ_pos_vector.x+7*math.sin(left_point), targ_pos_vector.y, targ_pos_vector.z+7*math.cos(left_point))
  self:draw_line(left_vector, targ_pos_vector)

  left_vector = Vector3.New(targ_pos_vector.x+7*math.sin(left_point), targ_pos_vector.y, targ_pos_vector.z+7*math.cos(left_point))
  self:draw_line(left_vector, targ_pos_vector)

  local last_vec = left_vector

  local angle_diff = math.rad(nAngle)

  local arc_start = targ_angle+(math.pi-angle_diff/2)
  local arc_end = (targ_angle+(math.pi-angle_diff/2))+angle_diff

  for i = arc_start, arc_end, (arc_end-arc_start)/nSegments do
    local new_vec = Vector3.New(targ_pos_vector.x + (7 * math.sin(i)), targ_pos_vector.y, targ_pos_vector.z + (7 * math.cos(i)))
    self:draw_line(last_vec,new_vec)
    last_vec = new_vec
  end



  local right_vector = Vector3.New(targ_pos_vector.x+7*math.sin(right_point), targ_pos_vector.y, targ_pos_vector.z+7*math.cos(right_point))
  self:draw_line(right_vector, targ_pos_vector)
end

function stalker_zone:draw_line(vec1, vec2)
  local start_point = GameLib.WorldLocToScreenPoint(vec1)
  local end_point = GameLib.WorldLocToScreenPoint(vec2)
  self.cPanel:AddPixie( {
    bLine = true, fWidth = 6, cr = "ff000000",
    loc = { fPoints = { 0, 0, 0, 0 }, nOffsets = { start_point.x, start_point.y, end_point.x, end_point.y } }
    })
  self.cPanel:AddPixie( {
    bLine = true, fWidth = 4, cr = "FFff00ff",
    loc = { fPoints = { 0, 0, 0, 0 }, nOffsets = { start_point.x, start_point.y, end_point.x, end_point.y } }
    })
end
  function round(v, p)
local mult = math.pow(10, p or 0) -- round to 0 places when p not supplied
    return math.floor(v * mult + 0.5) / mult;
end;

stalker_zone:new():init()
