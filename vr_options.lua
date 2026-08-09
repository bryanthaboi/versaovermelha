local SCREEN_ID = "VersaoVermelhaOptions"

local M = {}

function M.install(mod)

  -- ==========================================
  -- Opções persistentes
  -- ==========================================

  mod.options:define({
    {
      key = "idioma_golpes",
      type = "choice",
      default = "portuguese1",
      choices = {
        { "PT-BR  (17)", "portuguese1" },
        --{ "PT-BR  (12)", "portuguese2" },
		{ "INGLÊS (12)", "english" },
      },
    },

    {
      key = "mostrar_inimigo",
      type = "choice",
      default = false,
      choices = {
        { "SIM", true },
        { "NÃO", false },
      },
    },

    {
      key = "precos_linha",
      type = "choice",
      default = true,
      choices = {
        { "LINHA DE BAIXO", true },
        { "MESMA LINHA", false },
      },
    },

    {
      key = "trainer_card",
      type = "choice",
      default = true,
      choices = {
        { "CORRIGIDO", true },
        { "ORIGINAL", false },
      },
    },
  })

  -- ==========================================
  -- Funções de opção
  -- ==========================================

  local function getOption(game, key)
    local options = game.save and game.save.options

    local bucket = options
      and options.modOptions
      and options.modOptions[mod.id]

    if bucket and bucket[key] ~= nil then
      return bucket[key]
    end

    return mod.options:get(key)
  end

  local function setOption(game, key, value)
    game.save.options.modOptions =
      game.save.options.modOptions or {}

    game.save.options.modOptions[mod.id] =
      game.save.options.modOptions[mod.id] or {}

    game.save.options.modOptions[mod.id][key] = value

    if game.mods then
      game.mods.modOptions =
        game.mods.modOptions or {}

      game.mods.modOptions[mod.id] =
        game.mods.modOptions[mod.id] or {}

      game.mods.modOptions[mod.id][key] = value
    end

    if game.writeOptions then
      game:writeOptions()
    end
  end

  -- ==========================================
  -- Tela de opções
  -- ==========================================

  mod.content.screens:register(SCREEN_ID, {
    new = function(game)
  if mod.exports.precos_linha == nil then
    mod.exports.precos_linha = true
  end

  if mod.exports.trainer_card == nil then
    mod.exports.trainer_card = true
  end
      local Font = mod.ui.Font

      -- Carrega os valores salvos
      mod.exports.idioma_golpes =
        getOption(game, "idioma_golpes")

      mod.exports.mostrar_inimigo =
        getOption(game, "mostrar_inimigo")

      mod.exports.precos_linha =
        getOption(game, "precos_linha")

      mod.exports.trainer_card =
        getOption(game, "trainer_card")

      local rows = {
        {
          label = "IDIOMA DOS GOLPES",
          key = "idioma_golpes",
          value = mod.exports.idioma_golpes,
        },

        {
          label = "MOSTRAR “INIMIGO”",
          key = "mostrar_inimigo",
          value = mod.exports.mostrar_inimigo,
        },

        {
          label = "PREÇOS E QTDs.",
          key = "precos_linha",
          value = mod.exports.precos_linha,
        },

        {
          label = "TRAINER CARD",
          key = "trainer_card",
          value = mod.exports.trainer_card,
        },
      }

      local screen = {
        game = game,
        rows = rows,
        index = 1,
        isOpaque = true,
      }

      function screen:update()
        local input = game.input
        local row = self.rows[self.index]

        if input:wasPressed("up") then

          self.index = self.index > 1
            and self.index - 1
            or #self.rows

        elseif input:wasPressed("down") then

          self.index = self.index < #self.rows
            and self.index + 1
            or 1

        elseif input:wasPressed("left")
          or input:wasPressed("right")
          or input:wasPressed("a") then

          -- ==========================================
          -- IDIOMA DOS GOLPES
          -- ==========================================

          if self.index == 1 then

            if row.value == "english" then
              row.value = "portuguese1"

            --elseif row.value == "portuguese1" then
            --w  row.value = "portuguese2"

            else
              row.value = "english"
            end

            setOption(
              game,
              "idioma_golpes",
              row.value
            )

            mod.exports.idioma_golpes = row.value

          -- ==========================================
          -- MOSTRAR "INIMIGO"
          -- ==========================================

          elseif self.index == 2 then

            row.value = not row.value

            setOption(
              game,
              "mostrar_inimigo",
              row.value
            )

            mod.exports.mostrar_inimigo = row.value

          -- ==========================================
          -- PREÇOS E QTDs.
          -- ==========================================

          elseif self.index == 3 then

            row.value = not row.value

            setOption(
              game,
              "precos_linha",
              row.value
            )

            mod.exports.precos_linha = row.value

          -- ==========================================
          -- TRAINER CARD
          -- ==========================================

          elseif self.index == 4 then

            row.value = not row.value

            setOption(
              game,
              "trainer_card",
              row.value
            )

            mod.exports.trainer_card = row.value
          end

        elseif input:wasPressed("b") then
          game.stack:pop()
        end
      end

      function screen:draw()

        Font.drawBox(0, 0, 20, 18)

        for i, row in ipairs(self.rows) do

          local y = 8 + (i - 1) * 24

          if i == self.index then
            Font.drawCode(0xED, 16, y + 8)
          end

          Font.draw(row.label, 16, y)

          local value = row.value

          if row.key == "idioma_golpes" then

            if value == "english" then
              value = "INGLÊS (12)"

            elseif value == "portuguese1" then
              value = "PT-BR  (17)"

            elseif value == "portuguese2" then
              value = "PT-BR  (12)"
            end

          elseif row.key == "mostrar_inimigo" then

            value = value and "SIM" or "NÃO"

          elseif row.key == "precos_linha" then

            value = value and "LINHA DE BAIXO" or "MESMA LINHA"

          elseif row.key == "trainer_card" then

            value = value and "CORRIGIDO" or "ORIGINAL"
          end

          Font.draw(value, 24, y + 8)
        end

        Font.draw("B: VOLTAR", 8, 112)
		Font.draw("OBS: RESETE PARA", 8, 120)
		Font.draw("     OPÇÕES 1 E 2", 8, 128)
      end

      return screen
    end,
  })

  -- ==========================================
  -- OPTIONS > MODS
  -- ==========================================

  mod.hooks:wrap("ui.options.rows", function(next, game, rows)

    local out = next(game, rows)

    if type(out) ~= "table" then
      return out
    end

    return mod.ui.insertBefore(out, "MODS", {
      id = "versaovermelha",

      label = "VERSÃO BRASILEIRA",

      value = function()
        return " OPÇÕES EXTRAS"
      end,

      activate = function(g)
        mod.ui.push(g, SCREEN_ID)
      end,
    })
  end)
end

return M