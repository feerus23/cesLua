script_name('Configurable Emergency Stroboscope')
script_author('Fuexie')
script_version('0.0')
script_url('t.me/fuexiesworks')
script_version_number(000)

local scr = thisScript()
------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- Тут короче будет всякая херня в кучу.
--
local rqs = {}
rqs['lfs'], lfs = pcall(require, 'lfs')

for k, v in pairs(rqs) do
  assert(v, k.." module wasn't found")
end

local han

local ccd = {}

local data = {
  cd = getWorkingDirectory()..'\\CESL'
}

local cd = data.cd

function chars(s)
  local i = 0
  return function()
    if i < #s then
      i = i + 1

      return s:sub(i,i), i
    end
  end
end

function table.inscharval(t, p, v)
  if type(t) == 'table' then
    if t[p] then
      t[p] = t[p]..v
    else
      t[p] = v
    end
  end
end

function table.len(t)
  if type(t) == 'table' then
    local counter = 0

    for _ in pairs(t) do
      counter = counter + 1
    end

    return counter
  else
    return nil
  end
end
------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- Загрузка конфигураций
--
function readConfig(con)
  local _table, jusTmp = { }, { { }, { }, { } }
  local sc = { 1, 1, 1 }

  local file, err = io.open(cd..'\\'..con, 'r')
  if not file then
    return nil, err
  else
    for l in file:lines() do
      for c in chars(l) do
        if c == '#' then
          break
        end

        if c ~= ' ' then
          if c == ',' or c == ';' then
            if c == ';' and sc[1] > 4 then
              sc[3] = 1
              sc[2] = sc[2] + 1
            elseif c == ',' and sc[1] > 4 then
              sc[3] = sc[3] + 1
            else
              sc[1] = sc[1] + 1
            end
          else
            if sc[1] > 4 then
              table.inscharval(jusTmp[sc[2]], sc[3], c)
              --print(sc[3], c)
            else
              table.inscharval(jusTmp[sc[2]], sc[1], c)
              print(sc[1], c)
            end
          end
        end
      end
    end
  end

  print(jusTmp[1][2])

  do
    _table = {
      vehicle_id = jusTmp[1][1],
      num_of_config = jusTmp[1][2],
      right_state = jusTmp[1][3],
      left_state = jusTmp[1][4]
    }
  end

  return _table
end

------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- Загрузка конфигураций
--
function main()
  while not isSampAvailable() do wait(100) end

  --sampRegisterChatCommand('/tst', function () local integ = readConfig('example.cesl'); print(integ.vehicle_id, integ.num_of_config) end)
  readConfig('example.cesl')

  while true do
    wait(0)

  end
end

------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- Цели:
-- - Написать функцию, загружающую информацию конфига в таблицу (0.2)
-- - Написать функцию, читающую все конфигурации из директории (0.3)
-- - Написать класс стробоскопа (0.4)
--    - Написать метод запуска стробоскопов (0.42)
--    - Написать метод двухпоточного мигания епта (0.44)
--    - Написать метод остановки стробоскопов (0.46)
--    - Написать метод изменения конфигурации (0.5)
