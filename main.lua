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


return function(mod)
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
  counts.species = each("species_names", function(id, value)
    mod.content.pokemon:patch(id, { name = value })
  end)
  counts.moves = each("move_names", function(id, value)
    mod.content.moves:patch(id, { name = value })
  end)
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
  -- Battle UI
  -------------------------------------------------------------------------
local function displayName(b)
  return b.isPlayer and b.name or ("" .. b.name)
end

-- Apply the "Enemy " prefix to a pre-built message from a module that
-- only knows the raw nickname (Status.beforeMove/residual,
-- TrainerAI.useItem): splice it in before the first name occurrence.
local function prefixEnemy(msg, battler)
  if battler.isPlayer then return msg end
  local s = msg:find(battler.name, 1, true)
  if not s then return msg end
  return msg:sub(1, s - 1) .. "" .. msg:sub(s)
end


  BattleState.drawTextArea = function(self)

function BattleState:drawTextArea()
  Font.drawBox(0, 12, 20, 6)
  love.graphics.setColor(0, 0, 0, 1)
  if self.phase == "messages" and (self.current or self.animPlaying) then
    -- during the move animation self.current is nil but shown still holds
    -- the "used X!" lines; keep drawing them like pokered, whose move
    -- animations only touch sprites and never the textbox tilemap (#296)
    -- rolling 2-line window: shown[1] at row y=112, shown[2] at y=128 (battle
    -- text uses every other tile row, hlcoord *,14 / *,16).  scrollPx animates
    -- the lines up one row (ScrollTextUpOneLine) so a 3rd line scrolls into
    -- view instead of drawing off-screen at y=144 (#216).
    if self.scrollPx and self.scrollPx > 0 then
      self.scrollPx = self.scrollPx - 2
      if self.scrollPx <= 0 then self.scrollPx = nil end
    end
    local off = self.scrollPx or 0
    local ys = { 112, 128 }
    for li, line in ipairs(self.shown or {}) do
      local y = (ys[li] or 128) + off
      for i = 1, #line do
        Font.drawCode(line[i], 8 + (i - 1) * 8, y)
      end
    end
    -- the blinking down arrow ('▼', glyph $EE) while a \v CONT wait
    -- (_ContText) or a typed-out page (PromptText) holds the box; both write
    -- it at (18,16), bottom-right, like TextBox / home/text.asm (#317)
    if (self.msgWaiting or self.msgPrompt) and self.frame % 60 < 30 then
      Font.drawCode(0xEE, (0 + 20 - 2) * 8, (12 + 6 - 1) * 8 - 4)
    end
  elseif self.phase == "menu" and self.demo then
    -- the old-man script (DisplayBattleMenu, core.asm:2038-2049): the
    -- standard menu, with the '▶' hand drawn by the scripted keystrokes
    -- -- next to FIGHT (9,14) for the first 80 frames, then ITEM (9,16)
    Font.drawBox(5, 12, 15, 6)
    love.graphics.setColor(0, 0, 0, 1)
    Font.draw(Strings("LUTAR"), 56, 112)
    Font.drawCode(0xE1, 112, 112); Font.drawCode(0xE2, 120, 112)
    Font.draw(Strings("ITENS"), 56, 128); Font.draw(Strings("HYD~"), 112, 128)
    Font.drawCode(0xED, 48, (self.demoTimer or 0) <= 80 and 112 or 128)
  elseif self.phase == "menu" then
    local col = (self.menuIndex - 1) % 2
    local row = math.floor((self.menuIndex - 1) / 2)
    if self.safari then
      -- SAFARI_BATTLE_MENU_TEMPLATE: full-width box, "BALLx  BAIT /
      -- THROW ROCK  RUN" from (2,14)
      Font.drawBox(0, 12, 20, 6)
      Font.draw(Strings("BOLA SAFÁRI"), 16, 112); Font.draw(Strings("ISCA"), 112, 112)
      Font.draw(Strings("JOGAR PEDRA"), 16, 128); Font.draw(Strings("FUGIR"), 112, 128)
      Font.drawCode(0xED, (col == 0 and 8 or 104), 112 + row * 16)
    else
      -- BATTLE_MENU_TEMPLATE: box (8,12)-(19,17), "FIGHT <PK><MN> /
      -- ITEM  RUN" from (10,14); cursor columns 9 / 15
      Font.drawBox(5, 12, 15, 6)
      Font.draw(Strings("LUTAR"), 56, 112)
      Font.drawCode(0xE1, 112, 112); Font.drawCode(0xE2, 120, 112)
      Font.draw(Strings("ITENS"), 56, 128); Font.draw(Strings("FUGIR"), 112, 128)
      Font.drawCode(0xED, (col == 0 and 48 or 104), 112 + row * 16)
    end
  elseif self.phase == "moveSelect" then
    -- pokered MoveSelectionMenu: move list in a box at (4,12) 16x6,
    -- names at column 6 from row 13, cursor at column 5.  PrintMenuItem:
    -- the TYPE/PP box at (0,8) 11x5, with "TYPE/" at (1,9), the type at
    -- (2,10) and "PP cur/max" at (5,11); its bottom border merges into
    -- the move box's top border ('─' at (4,12), '┘' at (10,12)).
    Font.drawBox(0, 8, 11, 5)
    Font.drawBox(0, 12, 20, 6)
    -- Those two cells are REPLACED on hardware: MoveSelectionMenu writes them
    -- straight into the tilemap over the border it just laid down
    -- (core.asm:2492-2501), and PrintMenuItem's own TextBoxBorder then redraws
    -- the whole row on top (core.asm:2838-2844).  Font.drawCode blits a
    -- black-on-transparent glyph instead, so the tile underneath survives: the
    -- move box's '┌' keeps its Poké Ball corner showing through the '─', and
    -- the '─' the move box drew at (10,12) pokes two dots out from under the
    -- '┘' (#240).  Wipe each cell back to box white first, the way a tilemap
    -- write does.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 32, 96, 8, 8)
    love.graphics.rectangle("fill", 80, 96, 8, 8)
    Font.drawCode(Font.BORDER.h, 32, 96)
    Font.drawCode(Font.BORDER.br, 80, 96)
    love.graphics.setColor(0, 0, 0, 1)
    for i, mv in ipairs(self.player.curMoves) do
      -- unknown ids (mod-injected moves) print raw instead of crashing
      local def = self.data.moves[mv.id]
      Font.draw(def and def.name or tostring(mv.id), 16, 96 + i * 8)
    end
    Font.drawCode((self.moveSwapIndex == self.moveIndex) and 0xEC or 0xED,
                  08, 96 + self.moveIndex * 8)
    if self.moveSwapIndex and self.moveSwapIndex ~= self.moveIndex then
      Font.drawCode(0xEC, 40, 96 + self.moveSwapIndex * 8)
    end
    local sel = self.player.curMoves[self.moveIndex]
    if sel then
      local def = self.data.moves[sel.id]
      if self.player.disabledSlot == self.moveIndex then
        Font.draw(Strings("disabled!"), 8, 80)
      elseif def then
        Font.draw(Strings("TYPE/"), 8, 72)
        -- the type record's display name (a mod type shows its name, and
        -- PSYCHIC_TYPE prints PSYCHIC like the original)
        Font.draw(def.type and TypeChart.displayName(def.type) or "", 16, 80)
        local maxPP = def.pp + (sel.ppUps or 0) * math.floor(def.pp / 5)
        Font.draw(("%2d/%2d"):format(sel.pp, maxPP), 40, 88)
      end
    end
  elseif self.phase == "mimicSelect" then
    -- Mimic's copy menu (MoveSelectionMenu .mimicmenu, core.asm:
    -- 2506-2517): the enemy's move list in a 16x6 box at (0,7), names
    -- single-spaced from (2,8), cursor at column 1
    Font.drawBox(0, 7, 16, 6)
    love.graphics.setColor(0, 0, 0, 1)
    for i, m in ipairs(self.mimicMoves) do
      Font.draw(self.data.moves[m.id].name, 16, (7 + i) * 8)
    end
    Font.drawCode(0xED, 8, (7 + self.mimicIndex) * 8)
  end
end

  end
  
  local literal_body = mod:read("lang/literal_handlers.lua")
  if literal_body then
    local chunk, err = loadstring(literal_body, "lang/literal_handlers.lua")
    if not chunk then error(err) end
    local setup = chunk()
    if type(setup) ~= "function" then error("literal_handlers.lua must return a function") end
    setup(mod)
  end
  
  
  
  
end
