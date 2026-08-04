-- Generated qid-driven literal dialogue handlers.
return function(mod)
  local TextBox = mod.ui.TextBox
  local ChoiceBox = mod.ui.ChoiceBox
  mod.content.map_scripts:register("VIRIDIAN_CITY", {talk = {
    ["TEXT_VIRIDIANCITY_YOUNGSTER2"] = function(game, ow, npc, done)
      game.stack:push(TextBox.new(game, "Quer saber sobre\nos 2 tipos de\011lagartas POKéMON?", function()
        game.stack:push(ChoiceBox.new(game, function(yes)
          game.stack:push(TextBox.new(game, yes and "CATERPIE não tem\nveneno, mas o\011WEEDLE tem.\012Cuidado com o seu\nFERRÃO VENENOSO!" or "Ah, tudo bem\nentão!", done))
        end))
      end))
    end,
  },
  })
  mod.content.map_scripts:register("MUSEUM_1F", {talk = {
    ["TEXT_MUSEUM1F_SCIENTIST1"] = function(game, ow, npc, done)
      if game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] then
        game.stack:push(TextBox.new(game, "Fique à vontade\npara olhar o\011tempo que quiser!", done))
      else
        game.stack:push(TextBox.new(game, "Custa ¥50 por um\nbilhete infantil.\012Gostaria de\nentrar?", function()
          game.stack:push(ChoiceBox.new(game, function(yes)
            if yes then
              if (game.save.money or 0) >= 50 then
                game.save.money = (game.save.money or 0) + (-50)
                game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] = true
                game.stack:push(TextBox.new(game, "50¥! Perfeito!\nObrigado!", done))
              else
                game.stack:push(TextBox.new(game, "Você não tem di\nheiro suficiente.", done))
              end
            else
              game.stack:push(TextBox.new(game, "Volte sempre!", done))
            end
          end))
        end))
      end
    end,
  },
    onStep = function(game, ow, x, y)
      if ((x == 9 and y == 4) or (x == 10 and y == 4)) and not game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] then
        local function on_done() end
        game.stack:push(TextBox.new(game, "Custa ¥50 por um\nbilhete infantil.\012Gostaria de\nentrar?", function()
          game.stack:push(ChoiceBox.new(game, function(yes)
            if yes then
              if (game.save.money or 0) >= 50 then
                game.save.money = (game.save.money or 0) + (-50)
                game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] = true
                game.stack:push(TextBox.new(game, "Certo, ¥50!\nObrigado!", on_done))
              else
                game.stack:push(TextBox.new(game, "Você não tem di\nheiro suficiente.", function()
                  ow:scriptMove(ow.player, "down", 1, on_done)
                end))
              end
            else
              game.stack:push(TextBox.new(game, "Volte sempre!", function()
                ow:scriptMove(ow.player, "down", 1, on_done)
              end))
            end
          end))
        end))
        return true
      end
      return false
    end,
  })
  mod.content.map_scripts:register("BIKE_SHOP", {talk = {
    ["TEXT_BIKESHOP_CLERK"] = function(game, ow, npc, done)
      if (game.save.inventory["BICYCLE"] or 0) > 0 then
        game.stack:push(TextBox.new(game, "O que achou da sua\nnova BICICLETA?\012Você pode pedalar\ncom ela na ROTA\011DO CICLISMO e\011até em cavernas!", done))
      else
        if (game.save.inventory["BIKE_VOUCHER"] or 0) > 0 then
          game.stack:push(TextBox.new(game, "Oh, isso é um...\012VALE-BICICLETA!\012OK! Aqui está!", function()
            game.save.inventory["BIKE_VOUCHER"] = nil
            game.save.inventory["BICYCLE"] = 1
            game.save.flags["EVENT_GOT_BICYCLE"] = true
            game.stack:push(TextBox.new(game, "{PLAYER} trocou\no VALE-BICICLETA\011por uma BICICLETA.", done))
          end))
        else
          game.stack:push(TextBox.new(game, "Olá! Bem-vindo\na minha LOJA\011DE BICICLETAS.\012Nós temos a\nbicicleta ideal\011para você!", done))
        end
      end
    end,
  },
  })
  mod.content.map_scripts:register("BIKE_SHOP", {talk = {
    ["TEXT_BIKESHOP_MIDDLE_AGED_WOMAN"] = function(game, ow, npc, done)
      game.stack:push(TextBox.new(game, "Uma BICICLETA\nsimples pra usar\011na cidade já está\011bom pra mim!\012Não tem como por\numa cestinha de\011compras em uma\011Mountain BIKE!", done))
    end,
  },
  })
  mod.content.map_scripts:register("BIKE_SHOP", {talk = {
    ["TEXT_BIKESHOP_YOUNGSTER"] = function(game, ow, npc, done)
      if (game.save.flags["EVENT_GOT_BICYCLE"] or (game.save.inventory["BICYCLE"] or 0) > 0) then
        game.stack:push(TextBox.new(game, "Uau! Sua BICICLETA\né super legal!", done))
      else
        game.stack:push(TextBox.new(game, "Essas BICICLETAs\nsão legais, mas\011são muito caras!", done))
      end
    end,
  },
  })
end
