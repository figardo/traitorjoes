include("shared.lua")

local text = "Press E to toggle radio."
function ENT:TraitorJoeTargetID()
	if IsValid(self:GetParent()) then return end

	local font = "TargetIDSmall"
	surface.SetFont( font )

	local w = surface.GetTextSize(text)
	local x_orig = ScrW() / 2.0
	local x = x_orig - w / 2
	local y = (ScrH() / 2.0) + 30
	draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
	draw.SimpleText( text, font, x, y, COLOR_LGRAY )
end