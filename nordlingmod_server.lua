nordlingmod = {
}

local log = radiant.log.create_logger('Nordling Mod Server')


function nordlingmod:_on_required_loaded()
  local BeeTrapper = require('jobs.trapper')
  local BeeTrappingGrounds = require('components.trapping.trapping_grounds_component')
  log:always("Bees Loaded")

end

radiant.events.listen_once(radiant,'radiant:required_loaded', nordlingmod, nordlingmod._on_required_loaded)

return nordlingmod