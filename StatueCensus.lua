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
colors.tank = '\\cs(0,170,255)' --blue
colors.dps = '\\cs(255,50,50)' --red
colors.healer = '\\cs(100,255,100)' --green
colors.close = '\\cr'

local StatueCensus = {}

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
defaults.colors.Warrior = colors.tank
defaults.colors.Rune Fencer = colors.tank
defaults.colors.Paladin = colors.tank

defaults.colors.White Mage = colors.healer
defaults.colors.Red Mage = colors.dps

defaults.colors.Monk = colors.dps
defaults.colors.Black Mage = colors.dps
defaults.colors.Thief = colors.dps
defaults.colors.Bard = colors.dps
defaults.colors.Beastmaster = colors.dps
defaults.colors.Dark Knight = colors.dps
defaults.colors.Ranger = colors.dps
defaults.colors.Summoner = colors.dps
defaults.colors.Dragoon = colors.dps
defaults.colors.Ninja = colors.dps
defaults.colors.Samurai = colors.dps
defaults.colors.Blue Mage = colors.dps
defaults.colors.Corsair = colors.dps
defaults.colors.Puppetmaster = colors.dps
defaults.colors.Dancer = colors.dps
defaults.colors.Scholar = colors.dps
defaults.colors.Geomancer = colors.dps

StatueCensus.settings = config.load(defaults)
StatueCensus.text = require('texts').new(StatueCensus.settings.text, StatueCensus.settings)



divergence_zone_ids = T{294, 295, 296, 297} --might need to require('tables') for T to be defined

--census data in format of census_data[zone_id][mob_id][mob_x, mob_y, mob_z][main_job, sub_job]
--contains table of each mob jobs
census_data = {
  --sandy
  294 = {
    1 = { --1 for now - replace with id of the red eyes on top of the AH in wave 1
      {'nin', 'blu'},
      {'thf', 'dnc'}
    },
    2 = {
      {'nin'},
      {'pld'},
      {'whm'},
    }
  },

  --bastok
  295 = {},

  --windy
  296 = {},

  --jeuno
  297 = {},
}

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

  local target = windower.ffxi.get_target_by_id(target_id)

  local target_info = get_target_info(target_id)
  if not target_info then
      StatueCensus.text:text('No data for ' .. target.name .. ' (%s)':format(target_id))
      StatueCensus.text:show()
    return
  end

  local text = target.name .. ':\n'
  for _, job in ipairs(target_info) do
    text = text .. '  - ' .. job .. '\n'
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
