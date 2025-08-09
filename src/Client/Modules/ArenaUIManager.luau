local ArenaUIManager = {}

function ArenaUIManager.clearCarousel(carouselFrame)
	for _, child in pairs(carouselFrame:GetChildren()) do
		if not child:IsA("UIGridLayout") or child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

function ArenaUIManager.clearPlayerIcons(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child.Name:match("^Player_") then
			child:Destroy()
		end
	end
end


return ArenaUIManager
