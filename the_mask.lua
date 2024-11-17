-- Function to mask the sprite by layers
function maskSpriteByLayers(sprite, targetLayerName, targetFrame)
   local targetLayer = nil
   for _, layer in ipairs(sprite.layers) do
      if layer.name == targetLayerName then
         targetLayer = layer
         break
      end
   end

   if not targetLayer then
      app.alert("Layer '" .. targetLayerName .. "' not found.")
      return
   end

   if targetLayer.isImage then
      local width = sprite.width
      local height = sprite.height

      for x = 0, width - 1 do
         for y = 0, height - 1 do
            local emptyPixel = true

            for j, layer in ipairs(sprite.layers) do
               if layer.name ~= targetLayerName and layer.isImage then
                  local cel = layer:cel(targetFrame)
                  if cel and cel.image then
                     local localX = x - cel.position.x
                     local localY = y - cel.position.y
   
                     if localX >= 0 and localX < cel.image.width and localY >= 0 and localY < cel.image.height then
                        local color = cel.image:getPixel(localX, localY)
                        local alpha = app.pixelColor.rgbaA(color)
   
                        if alpha > 0 then
                           emptyPixel = false
                           break
                        end
                     end
                  end
               end
            end

            if emptyPixel then
               local targetCel = targetLayer:cel(targetFrame)
               if targetCel then
                  local targetImage = targetCel.image
                  targetImage:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, 0))
               end
            end
         end
      end
   end
end

-- Main script
if debug.getinfo(2) == nil then
   local dlg = Dialog("Mask by Bradly Landucci")
   dlg:entry{
      id = "maskEntry",
      label = "Mask Layer",
      text = "",
      focus = "false"
  }
   dlg:newrow()
   dlg:entry{
      id = "frameEntry",
      label = "Target Frame",
      text = "",
      focus = "false"
   }
   dlg:newrow()
   dlg:button{
      id = "mask",
      text = "Mask",
      onclick = function()
         local inputLayerName = dlg.data.maskEntry
         local inputFrame = dlg.data.frameEntry
         local sprite = app.activeSprite
   
         if not sprite then
            app.alert("No active sprite to modify.")
            return
         end
   
         app.transaction(function()
            maskSpriteByLayers(sprite, inputLayerName, inputFrame)
         end)
   
         app.refresh()
      end
   }
   dlg:button{id = "close", text = "Close", onclick = function() dlg:close() end }
   dlg:show()
end

return 0