-- VersãoVermelha: a translation of the game into Português.
--
-- Nothing here is translated yet.  Every table under lang/ starts with
-- empty strings; fill one in and it takes effect on the next boot, and
-- anything still empty keeps rendering in English.  That means a
-- half-finished translation is always playable, so you can ship early and
-- fill the long tail in later.
--
-- Read TRANSLATING.md before the first edit; the font is the part people
-- get wrong.
local BattleState = require("src.battle.BattleState")
local Font = require("src.render.Font")
local Strings = require("src.core.Strings")
local TypeChart = require("src.battle.TypeChart")
local ListMenu = require("src.ui.ListMenu")
local MoveLearnMenu = require("src.ui.MoveLearnMenu")
local Theme = require("src.ui.Theme")
local TrainerCard = require("src.ui.TrainerCard")
local Badges = require("src.inventory.Badges")

return function(mod)

  local compile = loadstring or load

  local source, err = mod:read("vr_options.lua")
  if not source then
    mod.log:error("cannot read vr_options.lua: %s", tostring(err))
    return
  end

  local chunk, err = compile(
    source,
    "@" .. mod.path .. "/vr_options.lua"
  )

  if not chunk then
    mod.log:error("cannot compile vr_options.lua: %s", tostring(err))
    return
  end

  local options = chunk()
  options.install(mod)
-- Carrega as opções persistentes para o restante do mod.
mod.exports.idioma_golpes =
    mod.options:get("idioma_golpes")

mod.exports.mostrar_inimigo =
    mod.options:get("mostrar_inimigo")

mod.exports.precos_linha =
    mod.options:get("precos_linha")

mod.exports.trainer_card =
    mod.options:get("trainer_card")

  -- mod:read is the supported way into your own directory; the catalogs are
  -- plain Lua tables, so read and run them rather than require()ing them.
  local function catalog(name)
    local rel = "lang/" .. name .. ".lua"
    local body = mod:read(rel)
    if not body then return {} end
    local chunk, err = loadstring(body, rel)
    if not chunk then
      mod.log:warn("%s has a syntax error: %s", rel, tostring(err))
      return {}
    end
    local ok, table_ = pcall(chunk)
    if not ok or type(table_) ~= "table" then
      mod.log:warn("%s did not return a table: %s", rel, tostring(table_))
      return {}
    end
    return table_
  end

  -- An empty value means "not translated yet", never "translate to blank".
  local function each(name, apply)
    local n = 0
    for key, value in pairs(catalog(name)) do
      if type(value) == "string" and value ~= "" then
        apply(key, value)
        n = n + 1
      end
    end
    return n
  end

  -- ---- glyphs -------------------------------------------------------
  -- Register the sheet BEFORE anything asks for a glyph on it.  base is
  -- the first code the page owns; 0x100 and up is free space above the
  -- vanilla pages, so a new alphabet never collides with them.
  for id, page in pairs(catalog("font")) do
    -- A page's `image` goes straight to love.graphics.newImage, which
    -- resolves against the game root rather than the mod, so a path that
    -- lives in this mod has to be made absolute or the page loads nothing
    -- and every accented character draws as a blank.  mod:read is the
    -- precise test for "this file is mine".
    if type(page) == "table" and type(page.image) == "string"
        and mod:read(page.image) then
      page.image = mod.assets:path(page.image)
    end
    mod.content.font:register(id, page)
	-- mod.content.font:register("ttf", {
    -- file = mod.assets:path("assets/fonts/plainpixel/Prop10.ttf"),
    -- size = 10,
    --})
  end
  -- charmap: which byte sequence draws which code
  for seq, code in pairs(catalog("charmap")) do
    mod.content.font:register("charmap:" .. seq, { seq = seq, code = code })
  end

  -- ---- text ---------------------------------------------------------
  local counts = {}
  counts.dialogue = each("dialogue", function(id, value)
    mod.content.text:override(id, value)
  end)
  counts.strings = each("strings", function(source, value)
    mod.content.strings:override(source, value)
  end)
  local mostrarInimigo = mod.options:get("mostrar_inimigo")

if mostrarInimigo then
  mod.content.strings:override("Enemy %s", "%s inimigo ")
  mod.content.strings:override("%s\nused %s!", "%s\nusou %s!")
else
  mod.content.strings:override("Enemy %s", "%s")
  mod.content.strings:override("%s\nused %s!", "%s usou\n%s!")
end

  
  
  counts.species = each("species_names", function(id, value)
    mod.content.pokemon:patch(id, { name = value })
  end)
 ---------------
 
 

-- Se for true, faz a alteração nos golpes

local idioma = mod.options:get("idioma_golpes")

if idioma == "portuguese1" then

    counts.moves = each("move_names", function(id, value)
        mod.content.moves:patch(id, { name = value })
    end)

elseif idioma == "portuguese2" then

    counts.moves = each("move_names2", function(id, value)
        mod.content.moves:patch(id, { name = value })
    end)

end



  
  
 ------------ 
  counts.items = each("item_names", function(id, value)
    mod.content.items:patch(id, { name = value })
  end)
  counts.trainers = each("trainer_names", function(id, value)
    mod.content.trainers:patch(id, { name = value })
  end)
  counts.statuses = each("status_labels", function(id, value)
    mod.content.statuses:patch(id, { label = value })
  end)

  -- ---- name entry ---------------------------------------------------
  -- The naming screen's letter grid.  Leave lang/naming.lua returning nil
  -- to keep the English alphabet.
  -- The mod-facing hook surface is :wrap(name, callback, priority); the
  -- generated template calls :on, which does not exist and only blows up
  -- once lang/naming.lua is actually filled in.
 -- local grid = catalog("naming")
 -- if grid.upper or grid.lower then
 --  mod.hooks:wrap("ui.naming.grid", function(base, ctx)
 --     local want = ctx and ctx.lower and grid.lower or grid.upper
 --     return want or base
 --   end)
 -- end

  mod.events:on("game.ready", function()
    local total = 0
    for _, n in pairs(counts) do total = total + n end
    mod.log:info("Português: %d strings traduzidas", total)
  end)
  
  
  
 
  
  
  
-------------------------------------------------------------------------
  -- Traduções Literais
-------------------------------------------------------------------------  
  local literal_body = mod:read("lang/literal_handlers.lua")
  if literal_body then
    local chunk, err = loadstring(literal_body, "lang/literal_handlers.lua")
    if not chunk then error(err) end
    local setup = chunk()
    if type(setup) ~= "function" then error("literal_handlers.lua must return a function") end
    setup(mod)
  end
-------------------------------------------------------------------------
  -- Correção do Inventário, Preços e Quantidades na linha debaixo


--- ==========================================
-- Cartão de Treinador
-- ==========================================
local oldTrainerCardDraw = TrainerCard.draw

TrainerCard.draw = function(self, ...)
    if not mod.exports.trainer_card then
        return oldTrainerCardDraw(self, ...)
    end

    local oldDraw = Font.draw
    local oldGfxDraw = love.graphics.draw
    local save = self.game.save

    Font.draw = function(text, x, y, ...)
        if x == 16 and y == 16 then
            oldDraw(
                Strings("NAME/%s", save.player.name or "RED"),
                16, 12, ...
            )

        elseif x == 16 and y == 32 then
            oldDraw(
                Strings("DINHEIRO/"),
                16, 25, ...
            )

            oldDraw(
                ("¥%d"):format(save.money or 0),
                48, 33, ...
            )

        elseif x == 16 and y == 48 then
            local t = math.floor(save.playTime or 0)

            oldDraw(
                Strings("TEMPO/"),
                16, 42, ...
            )

            oldDraw(
                ("%3d:%02d"):format(
                    math.floor(t / 3600),
                    math.floor(t / 60) % 60
                ),
                48, 50, ...
            )

        elseif x == 56 and y == 72 then
            oldDraw(
                Strings("BADGES"),
                40, 73, ...
            )

        else
            return oldDraw(text, x, y, ...)
        end
    end

    love.graphics.draw = function(image, ...)
        local args = {...}

        if image == self.circle then
            local x = args[1]
            local y = args[2]

            if x == 48 and y == 72 then
                args[1] = 32
                args[2] = 72

            elseif x == 104 and y == 72 then
                args[1] = 112
                args[2] = 72
            end

        elseif image == self.faces.img or image == self.badges.img then
            local x = args[2]
            local y = args[3]

            if x and y then
                local row = math.floor((y - 100) / 24)

                args[2] = x + 4
                args[3] = 97 + row * 22
            end
        end

        return oldGfxDraw(image, unpack(args))
    end

    local ok, a, b, c, d, e =
        pcall(oldTrainerCardDraw, self, ...)

    Font.draw = oldDraw
    love.graphics.draw = oldGfxDraw

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end

--------------------------------------------------------------
----------------------BATTLE UI
--------------------------------------------------------------
local oldDrawTextArea = BattleState.drawTextArea

BattleState.drawTextArea = function(self, ...)
    local oldDraw = Font.draw
    local oldDrawCode = Font.drawCode
	local oldDrawBox = Font.drawBox

    Font.draw = function(text, x, y, ...)
        if text == Strings("FIGHT", "battle") and x == 80 and y == 112 then
            x = 56
            y = 112

        elseif text == Strings("ITEM", "battle") and x == 80 and y == 128 then
            x = 56
            y = 128

        elseif text == Strings("RUN", "battle") and x == 128 and y == 128 then
            x = 112
            y = 128
		--LISTA DE GOLPES	
		elseif x == 48 and y >= 104 and y <= 128 then
        x = 16	
			
        end

        return oldDraw(text, x, y, ...)
    end

    Font.drawCode = function(code, x, y, ...)
	--PKMN
        if code == 0xE1 and x == 128 and y == 112 then
            x = 112
            y = 112

        elseif code == 0xE2 and x == 136 and y == 112 then
            x = 120
            y = 112
	--CURSORES DE BATALHA
        elseif code == 0xED and x == 72 and y == 112 then
            x = 48
            y = 112
        elseif code == 0xED and x == 120 and y == 112 then
            x = 104
            y = 112			
        elseif code == 0xED and x == 72 and y == 128 then
            x = 48
            y = 128			
        elseif code == 0xED and x == 120 and y == 128 then
            x = 104
            y = 128	
	--CURSORES DE GOLPES
			elseif code == 0xED and x == 40 and y == 104 then
            x = 08
            y = 104
		elseif code == 0xED and x == 40 and y == 112 then
            x = 08
            y = 112
		elseif code == 0xED and x == 40 and y == 120 then
            x = 08
            y = 120
		elseif code == 0xED and x == 40 and y == 128 then
            x = 08
            y = 128
		elseif code == 0xEC and x == 40 and y == 104 then
            x = 08
            y = 104				
		elseif code == 0xEC and x == 40 and y == 112 then
            x = 08
            y = 112
		elseif code == 0xEC and x == 40 and y == 120 then
            x = 08
            y = 120
		elseif code == 0xEC and x == 40 and y == 128 then
            x = 08
            y = 128		
	--CURSORES DE MIMIC
	
			
        end
		
		
		
		
		

        return oldDrawCode(code, x, y, ...)
    end
--FIGHT/PKMN/ITEM/RUN BOX
	Font.drawBox = function(x, y, w, h, ...)
			if x == 8 and y == 12 and w == 12 and h == 6 then
			x = 5
			y = 12
			w = 15
			h = 6
--MOVELIST BOX Font.drawBox(4, 12, 16, 6)			
			elseif x == 4 and y == 12 and w == 16 and h == 6 then
			x = 0
			y = 12
			w = 20
			h = 6
--MOVELIST TYPE BOX Font.drawBox(0, 8, 11, 5)			
			--elseif x == 0 and y == 8 and w == 11 and h == 5 then
			--x = 0
			--y = 8
			--w = 11
			--h = 5			
--MIMIC BOX Font.drawBox(0, 7, 16, 6)			
			elseif x == 0 and y == 7 and w == 16 and h == 6 then
			x = 0
			y = 7
			w = 20
			h = 6
--MOVE LEARN BOX Font.drawBox(0, 5, 20, 7)			
			elseif x == 4 and y == 5 and w == 16 and h == 7 then
			x = 0
			y = 5
			w = 20
			h = 7
    end

	
	

    return oldDrawBox(x, y, w, h, ...)
end


    local ok, a, b, c, d, e = pcall(oldDrawTextArea, self, ...)

	
	Font.drawBox = oldDrawBox
    Font.draw = oldDraw
    Font.drawCode = oldDrawCode

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end

----------------------------------------------
----LEARN MOVE BOX
----------------------------------------------
local oldMoveLearnDraw = MoveLearnMenu.draw

MoveLearnMenu.draw = function(self, ...)
    local oldDraw = Font.draw
    local oldDrawCode = Font.drawCode
    local oldDrawBox = Font.drawBox

    Font.draw = function(text, x, y, ...)
        -- Nomes dos golpes
        if x == 48 and y >= 48 and y <= 128 then
            x = 16
        -- CANCEL
        elseif text == Strings("CANCEL") and x == 48 then
            x = 16
        end

        return oldDraw(text, x, y, ...)
    end

    Font.drawCode = function(code, x, y, ...)
        -- Cursor da lista
        if code == 0xED and x == 40 then
        x = 8
		end

        return oldDrawCode(code, x, y, ...)
    end

    Font.drawBox = function(x, y, w, h, ...)
        -- Caixa da lista de golpes
        if x == 4 and y == 5 and w == 16 and h == 7 then
            x = 0
            y = 5
            w = 20
            h = 7
        end

        return oldDrawBox(x, y, w, h, ...)
    end

    local ok, a, b, c, d, e = pcall(oldMoveLearnDraw, self, ...)

    Font.draw = oldDraw
    Font.drawCode = oldDrawCode
    Font.drawBox = oldDrawBox

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end

----------------------------------------
--INVENTÁRIO - QUEBRA DE LINHA
----------------------------------------
local oldListMenuDraw = ListMenu.draw

ListMenu.draw = function(self, ...)
    local oldDraw = Font.draw
    local offset = mod.exports.precos_linha and 8 or 0

    Font.draw = function(text, x, y, ...)
        if x == 160 - 8 - Font.width(text) then
            y = y + offset
        end

        return oldDraw(text, x, y, ...)
    end

    local ok, a, b, c, d, e = pcall(oldListMenuDraw, self, ...)

    Font.draw = oldDraw

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end

-------------
mod.hooks:wrap("ui.party.submenu", function(next, game, items, mon, ctx)
    local result = next(game, items, mon, ctx)

    if type(result) == "table" then
        for _, item in ipairs(result) do
            if item.action == "switch" then
                item.label = "MOVER"
            end
        end
    end

    return result
end)
------------------
------------------
  local TitleState = require("src.ui.TitleState")
  local oldDraw = TitleState.draw

  TitleState.draw = function(self)
    oldDraw(self)

    if self.version and not self.yellow then
      local iw, ih = self.version:getDimensions()

      -- cobre a versão antiga
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle("fill", 40, 64, 104, 8)

      -- desenha a versão na nova ordem/posição
      if self.blue then
        love.graphics.draw(
          self.version,
          love.graphics.newQuad(88, 0, 72, 8, iw, ih),
          48, 64
        )
      else
        love.graphics.draw(
          self.version,
          love.graphics.newQuad(0, 0, 88, 8, iw, ih),
          40, 64
        )
      end
    end

    love.graphics.setColor(1, 1, 1, 1)
  end

---yellow
---------------
  

  
local TitleState = require("src.ui.TitleState")
local oldDraw = TitleState.draw
local Font = require("src.render.Font")

TitleState.draw = function(self)
  oldDraw(self)

local function easeNoOvershoot(t)
  if t <= 0 then return 0 end
  if t >= 1 then return 1 end

  local u = t - 1
  local v = 1 + 2.70158 * u * u * u + 1.70158 * u * u

  return math.min(v, 1)
end


  if self.yellow then

    -- contador da animação
    self.__testFrame = (self.__testFrame or 0) + 1

    local f = self.__testFrame

    -- começa em Y=-15 e cai até Y=56
    -- sem ultrapassar nem voltar
local t = math.min(1, math.max(0, (f - 4) / 15))
local y = math.floor(-15 + (56 + 15) * easeNoOvershoot(t))

    local text1 = "VERSÃO"
    local text2 = "AMARELA"

    local x1 = 10
    local x2 = 104

    local w1 = Font.width(text1)
    local w2 = Font.width(text2)

    -- fundos brancos
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", x1, y, w1, 8)
    love.graphics.rectangle("fill", x2, y, w2, 8)

    -- textos pretos
    love.graphics.setColor(0, 0, 0, 1)
    Font.draw(text1, x1, y)
    Font.draw(text2, x2, y)

    love.graphics.setColor(1, 1, 1, 1)
  end
end
------------------
------------------
end
