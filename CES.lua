script_name('Configurable Emergency Stroboscope <Lights>')
script_author('Fuexie')
script_version('0.9')
script_url('t.me/fuexiesworks')
script_version_number(090)

local scr = thisScript()

------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- Тут короче будет всякая херня в кучу.
--
local rqs = {}
rqs['lfs'], lfs = pcall(require, 'lfs')

for k, v in pairs(rqs) do
  assert(v, k.." lib wasn't found")
end

local han

local ccd = {}

local data = {
  cd = getWorkingDirectory()..'\\CESL'
}

local cd = data.cd

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

function table.empty(t)
  if type(t) == 'table' then
    if table.len(t) >= 1 then
      return false
    else
      return true
    end
  else
    return nil
  end
end

function isVarEmpty(var)
  _tmptable = {
    ["table"] = function (v)
      if table.empty(v) then
        return true
      end
    end,
    ["string"] = function (v)
      if v:match('^%s$') or v == '' then
        return true
      end
    end,
    ["number"] = function (v)
      if v then
        return true
      end
    end,
    ["nil"] = function (v) return true end
  }

  if _tmptable[type(var)](var) then
    return true
  else
    return false
  end
end

function chars(s)
  local i = 0
  return function()
    if i < #s then
      i = i + 1
      return i, s:sub(i,i)
    end
  end
end

function mergeChars(t, p, v)
  if type(t) == 'table' then
    if t[p] then
      t[p] = t[p]..v
      --print(p,v)
    else
      t[p] = v
      --print(p,v)
    end
  end
end

function showLocMes(mes, col)
  -- ну тут лютый код, я его ещё хотел в сниппеты сунуть, а потом подумал
  -- засмеют же блять.. И я его не сувал никуда... Ну в снипетты уж точно...

  if isVarEmpty(col) then col = -1 end

  if not isVarEmpty(mes) and type(mes) == 'string' then
    local largeMes, colBraces, counter, line = {}, false, 1, 1

    if #mes > 144 or string.len(mes) > 144 then
      for _, c in chars(mes) do
        if c == '{' then colBraces = true end
        if c == '}' then colBraces = false; counter = counter - 1 end

        if not colBraces then counter = counter + 1 end

        if (counter > 83) and (c == ' ') then
          largeMes[line] = largeMes[line]..' ...'; line = line + 1;
          largeMes[line] = '... '..c; counter = 1
        elseif (counter > 83) and (c == '.' or c == ',' or c == ';' or c == ':' or c == '?' or c == '!') then
          largeMes[line] = largeMes[line]..c; line = line + 1; counter = 1
        else
          mergeChars(largeMes, line, c)
        end
      end

      for _, v in pairs(largeMes) do
        local tre = v:gsub('%s+',' '); tre = tre:gsub('^%s+','')
        sampAddChatMessage(tre, col) -- or lmao xD (типа треколор ахАХХАХАХА)
      end
    else
      sampAddChatMessage(mes, col)
    end
  else
    return nil
  end
end

function intb(var)
  if var == 0 then return 1 else return 0 end
end

------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- Вся херня с сиренами
--
local siren = { thread = {  }, status = { } }

function siren:setData(ch, cid)
  local vid = getCarModel(ch)

  self.data = {
    cHan = ch,
    vehId = vid,
    cNum = cid,
    [0] = {
      s = ccd[vid][cid].right_state,
      i = ccd[vid][cid].right_switches
    },
    [1] = {
      s = ccd[vid][cid].left_state,
      i = ccd[vid][cid].left_switches
    }
  }
end

function siren:resetData(ch, cid)
  if self.thread[0]:status() == 'runing' then
    for i=0,1 do self.thread[i]:terminate(); self.thread[i] = nil end
  end
  self.data = nil
  self:setData(ch, cid)
end

function siren:togOn()
  if self.thread[0] then
    if self.thread[0]:status() == 'dead' then
      for i = 0, 1 do
        self.thread[i]:run(self, i)
      end
    end
  else
    for i = 0, 1 do
      self.thread[i] = lua_thread.create(self.process, self, i)
      self.status[0], self.status[1] = true, true
    end
  end
end

function siren:togOff()
  if table.len(self.thread) == 2 then
    for i = 0, 1 do
      self.thread[i]:terminate()
    end
  end
end

function siren:process(face)
  local shit = self.data
  local ptr = getCarPointer(shit.cHan) + 1440
  local status = shit[face].s

  while true do
    for _, v in ipairs(shit[face].i) do
      callMethod(7086336, ptr, 2, 0, face, status)
      status = intb(status)
      wait(v)
    end
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
      for _, c in chars(l) do
        if c == '#' then
          break
        end

        -- тут начинается лютый треш... решения элегантней не придумал.
        -- ну в общем, хоть и из говна и палок, но зато работает.
        if c ~= ' ' then
          if c == ',' and sc[1] > 4 then
            sc[2] = sc[2] + 1
          elseif c == ';' and sc[1] >= 4 then
            sc[3] = sc[3] + 1; sc[2] = 1
          elseif c == ',' or c == ';' then
            sc[1] = sc[1] + 1
          else
            --print(sc[3])
            if sc[1] > 4 then
              mergeChars(jusTmp[sc[3]], sc[2], c)
            else
              mergeChars(jusTmp[sc[3]], sc[1], c)
            end
          end
        end
      end
    end
  end

  for i, v in ipairs(jusTmp) do
    for j, w in ipairs(v) do
      jusTmp[i][j] = tonumber(w)
    end
  end

  do
    _table = {
      vehicle_id = jusTmp[1][1],
      num_of_config = jusTmp[1][2],
      right_state = jusTmp[1][3],
      left_state = jusTmp[1][4],
      rs = jusTmp[2], ls = jusTmp[3]
    }
  end

  return _table
end

function pReadConfig(path)
  local tmp = readConfig(path)

  local function tpn(var)
    if type(var) == 'number' and var then return true else return false end
  end

  if tpn(tmp.vehicle_id) and tpn(tmp.num_of_config) and tpn(tmp.right_state) and tpn(tmp.left_state) and not table.empty(tmp.rs) and not table.empty(tmp.ls) then
    return tmp
  else
    return nil
  end
end

local prc = pReadConfig

------------------------ (⁄ ⁄•⁄ω⁄•⁄ ⁄) ------------------------
-- основной блок
--
function init()
  ccd = {}

  for file in lfs.dir(cd) do
    if file ~= '.' or file ~= '..' then
      if file:upper():match('%.CESL$') then
        local gin = pReadConfig(file)

        if gin then
          if ccd[gin.vehicle_id] then
            ccd[gin.vehicle_id][gin.num_of_config] = {
              right_state = gin.right_state,
              left_state = gin.left_state,
              right_switches = gin.rs,
              left_switches = gin.ls
            }
          else
            ccd[gin.vehicle_id] = {
              [gin.num_of_config] = {
                right_state = gin.right_state,
                left_state = gin.left_state,
                right_switches = gin.rs,
                left_switches = gin.ls
              }
            }
          end
        end
      end
    end
  end

  return true
end

function main()
  while not isSampAvailable() do wait(100) end
  init()

  registerCommands()

  while true do
    wait(0)

  end
end

function registerCommands()
  for k, v in pairs(_COMMANDS) do
    sampRegisterChatCommand(k, v[1])
    if v[0] then
      for _, w in ipairs(v[0]) do
        sampRegisterChatCommand(w, v[1])
      end
    end
  end
end

local prfx = 'ces'
_COMMANDS = {
  [prfx] = {
    [0] = { prfx..'/help' },
    [1] = function (arg)
      if not isVarEmpty(arg) then
        if _COMMANDS[prfx..'/'..arg] then
          showLocMes(_COMMANDS[prfx..'/'..arg][2])
        else
          showLocMes("CES*: You entered an incorrect command, or this command doesn't exist")
          showLocMes("CES*: Example of a correctly specified command: /ces start or /ces/help start")
        end
      else
        for _, v in pairs(_COMMANDS) do
          showLocMes(v[2])
        end
      end
    end,
    [2] = "CES*: Use /"..prfx.." or /ces/help [command] -: to get full list of commands"
  },
  [prfx..'/tst'] = {
    [1] = function (arg)
      print(table.len(ccd))
      --showLocMes('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum condimentum dolor, eget urna porta, a facilisis neque viverra. Pellentesque tempus lectus feugiat tempus placerat.')
    end,
    [2] = "CES*: Use /"..prfx.."/tst -: prikolbasina"
  },
  [prfx..'/start'] = {
    [0] = { prfx..'/activate' },
    [1] = function (c)
      if isCharInAnyCar(PLAYER_PED) then
        if isVarEmpty(c) then c = 1 else c = tonumber(c) end

        local car = storeCarCharIsInNoSave(PLAYER_PED)

        --print(car, getCarModel(car))
        if not siren.data or getCarModel(car) ~= siren.data.vehId or cid ~= siren.data.cNum then siren:setData(car, c) end

        forceCarLights(storeCarCharIsInNoSave(PLAYER_PED), 0)
        siren:togOn()

        print(siren.status[0], siren.status[0])
      else
        showLocMes("CES*: You're not in the car")
      end
    end,
    [2] = "CES*: Use /"..prfx.."/start or /"..prfx.."/activate [config-number] -:"
  },
  [prfx..'/stop'] = {
    [0] = { prfx..'/deactivate' },
    [1] = function ()
      if isCharInAnyCar(PLAYER_PED) then
        if table.len(siren.thread) == 2 then

          if siren.status[0] and siren.status[1] then siren:togOff() end
          forceCarLights(storeCarCharIsInNoSave(PLAYER_PED), 0)

        end
      else
        showLocMes("CES*: You're not in the car")
      end
    end,
    [2] = "CES*: Use /"..prfx.."/stop or /"..prfx.."/deactivate -"
  }
}
