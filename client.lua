RegisterNetEvent('Christian:Pannel')
AddEventHandler('Christian:Pannel', function()
  local input = lib.inputDialog('RISCATTA CODICE', {{label = 'INSERISCI IL CODICE', type = "number"}})
 
  if not input then return end
  print(json.encode(input), input[1])

  local codice = tonumber(input[1])
  TriggerServerEvent('ChristianCheckCode', codice)
end)

RegisterNetEvent('Christian:ClipBoardClient')
AddEventHandler('Christian:ClipBoardClient', function(code)
  lib.setClipboard(code)
end)
