local SpawnKodaScript = class()

function SpawnKodaScript:start(ctx, data)
   local npc_population = stonehearth.population:get_population('human_npcs')
   self._sv.koda = npc_population:create_new_citizen('kitten_koda', 'male')

   local town = stonehearth.town:get_town(ctx.player_id)
   local spawn_location = radiant.terrain.find_placement_point(town:get_landing_location(), 15, 50)
   radiant.terrain.place_entity(self._sv.koda, spawn_location)
   radiant.effects.run_effect(self._sv.koda, 'stonehearth:effects:spawn_entity')
   
   self._sv.num_victims_remaining = town:get_citizens():get_size()
   if self._sv.num_victims_remaining > 10 then
      self._sv.num_victims_remaining = 10
   end
   self._sv.koda:get('stonehearth:animal_social'):set_target_player_id(ctx.player_id)
   self:_set_conversation_listener()
   
   self._sv.despawn_timer = stonehearth.calendar:set_persistent_timer('despawn koda', '4d', function()
         self:_despawn()
      end)
end

function SpawnKodaScript:_set_conversation_listener()
   self._conversation_end_listener = radiant.events.listen(self._sv.koda, 'stonehearth:conversation:end', function(e)
         self._sv.num_victims_remaining = self._sv.num_victims_remaining - 1
         if self._sv.num_victims_remaining <= 0 then
            self:_despawn()
         end
         radiant.entities.add_thought(e.target, 'stonehearth:thoughts:kitties:koda')
         radiant.on_game_loop_once('reset social satisfaction', function()
               radiant.entities.modify_resource(self._sv.koda, 'social_satisfaction', -100)
            end)
      end)
end

function SpawnKodaScript:restore()
   if self._sv.is_leaving then
      self:_despawn()
   else
      self:_set_conversation_listener()
   end
end

function SpawnKodaScript:_despawn()
   if radiant.entities.exists(self._sv.koda) then
      self._sv.koda:get_component('stonehearth:ai')
            :get_task_group('stonehearth:task_groups:solo:unit_control')
               :create_task('stonehearth:depart_visible_area', { give_up_after = '4h' })
                  :start()
      self._sv.is_leaving = true
   else
      self._sv.koda = nil
      self._sv.is_leaving = nil
   end
   
   if self._sv.despawn_timer then
      self._sv.despawn_timer:destroy()
      self._sv.despawn_timer = nil
   end
   if self._conversation_end_listener then
      self._conversation_end_listener:destroy()
      self._conversation_end_listener = nil
   end
end

return SpawnKodaScript
