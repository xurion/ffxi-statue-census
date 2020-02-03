--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of StatueCensus nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'StatueCensus'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.command = 'statuecensus'
_addon.version = '0.0.1'

config = require('config')

active = false

colors = {}
colors.blue = '0,170,255'
colors.green = '100,255,100'
colors.pink = '240,120,250'
colors.purple = '155,0,170'
colors.orange = '255,100,0'
colors.grey = '120,120,120'
colors.red = '255,50,50'

local defaults = {}
defaults.text = {}
defaults.text.pos = {}
defaults.text.pos.x = 0
defaults.text.pos.y = 0
defaults.text.bg = {}
defaults.text.bg.alpha = 150
defaults.text.bg.blue = 0
defaults.text.bg.green = 0
defaults.text.bg.red = 0
defaults.text.bg.visible = true
defaults.text.padding = 8
defaults.text.text = {}
defaults.text.text.font = 'Consolas'
defaults.text.text.size = 10
defaults.tracking = 'briareus'

defaults.colors = {}
defaults.colors.WAR = colors.blue
defaults.colors.RUN = colors.blue
defaults.colors.PLD = colors.blue

defaults.colors.WHM = colors.green

defaults.colors.RDM = colors.pink
defaults.colors.BLM = colors.pink
defaults.colors.SCH = colors.pink
defaults.colors.GEO = colors.pink
defaults.colors.BRD = colors.pink

defaults.colors.MNK = colors.purple
defaults.colors.THF = colors.purple
defaults.colors.DRK = colors.purple
defaults.colors.RNG = colors.purple
defaults.colors.DRG = colors.purple
defaults.colors.SAM = colors.purple
defaults.colors.COR = colors.purple
defaults.colors.DNC = colors.purple

defaults.colors.BST = colors.orange
defaults.colors.SMN = colors.orange
defaults.colors.PUP = colors.orange

defaults.colors.NIN = colors.red
defaults.colors.BLU = colors.red

local StatueCensus = {}

StatueCensus.settings = config.load(defaults)
StatueCensus.text = require('texts').new(StatueCensus.settings.text, StatueCensus.settings)

divergence_zone_ids = T{
  294, --sandy
  295, --bastok
  296, --windy
  297, --jeuno
  145, --giddeus for testing
}

statue_names = T{
  'Corporal Tombstone',
  'Regiment Tomestone',
}

--data in format of census_data[zone_id][mob_id_hex][mob_a, mob_b, ...][main_job, sub_job]
census_data = {
  --sandy
  [294] = {
    [1] = { --1 for now - replace with id of the red eyes on top of the AH in wave 1
      {'NIN', 'BLU'},
      {'THF', 'DNC'}
    },
    [2] = {
      {'NIN'},
      {'PLD'},
      {'WHM'},
    }
  },

  --bastok
  [295] = {},

  --windy
  [296] = {},

  --jeuno
  [297] = {},

  --giddeus
  [145] = {
    [279] = {
      {'THF', 'COR'},
      {'MNK', 'BLM'},
      {'WHM', 'SMN'},
    },
    [271] = {
      {'BLM'},
      {'RDM'},
      {'NIN'},
      {'BLU'},
    }
  },
}

function start_color(color)
  return '\\cs(' .. color .. ')'
end

function end_color()
  return '\\cr'
end

function get_target_info(target_id)
  return census_data[windower.ffxi.get_info().zone][target_id]
end

function is_in_divergence_zone()
  return divergence_zone_ids:contains(windower.ffxi.get_info().zone)
end

function init()
  if windower.ffxi.get_info().logged_in and is_in_divergence_zone() then
    active = true
  end
end

windower.register_event('load', function()
  init()
end)

windower.register_event('target change', function(target_id)
  if not active then
    StatueCensus.text:hide()
    return
  end

  local target = windower.ffxi.get_mob_by_target('t')

  if not target or not statue_names:contains(target.name) then
    StatueCensus.text:hide()
    return
  end

  local target_info = get_target_info(target_id)
  local text = target.name .. ' ' .. start_color(colors.grey) .. '(' .. target_id .. ')' .. end_color() .. '\n'

  if not target_info then
    text = text .. 'No data'
    StatueCensus.text:text(text)
    StatueCensus.text:show()
    return
  end

  for _, job in ipairs(target_info) do
    text = text .. '  - ' .. start_color(StatueCensus.settings.colors[job[1]]) .. job[1] .. end_color()
    if job[2] then
      text = text .. '/' .. start_color(StatueCensus.settings.colors[job[2]]) .. job[2] .. end_color()
    end
    text = text .. '\n'
  end

  StatueCensus.text:text(text)
  StatueCensus.text:show()
end)

windower.register_event('zone change', function(zone_id)
  if divergence_zone_ids:contains(zone_id) then
    active = true
  else
    active = false
  end
end)

windower.register_event('login', function()
  init()
end)

windower.register_event('logout', function()
  active = false
  StatueCensus.text:hide()
end)

return StatueCensus
