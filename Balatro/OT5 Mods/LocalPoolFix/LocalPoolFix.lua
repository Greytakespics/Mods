--- STEAMODDED HEADER

--- MOD_NAME: Local Pool Fix
--- MOD_ID: jen_localpoolfix
--- MOD_AUTHOR: [jenwalter666]
--- MOD_DESCRIPTION: Tries to address the error "attempt to get length of local 'pool' (a nil value)" in Almanac
--- BADGE_COLOR: 000000
--- PREFIX: jenlocalpoolfix
--- VERSION: 0.0.0
--- LOADER_VERSION_GEQ: 1.0.0

function SMODS.process_loc_text(ref_table, ref_value, loc_txt, key)
  if ref_table then
    local target = (type(loc_txt) == 'table') and
    ((G.SETTINGS.real_language and loc_txt[G.SETTINGS.real_language]) or loc_txt[G.SETTINGS.language] or loc_txt['default'] or loc_txt['en-us']) or loc_txt
    if key and (type(target) == 'table') then target = target[key] end
    if not (type(target) == 'string' or target and next(target)) then return end
    ref_table[ref_value] = target
  end
end

function SMODS.insert_pool(pool, center, replace)
    if pool and center then
      if replace == nil then replace = center.taken_ownership end
      if replace then
          for k, v in ipairs(pool) do
              if v.key == center.key then
                  pool[k] = center
              end
          end
      else
          local prev_order = (pool[#pool] and pool[#pool].order) or 0
          if prev_order ~= nil then 
              center.order = prev_order + 1
          end
          table.insert(pool, center)
      end
    end
end