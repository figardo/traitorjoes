include("shared.lua")

function ENT:Initialize()
	self.loading = false
end

function ENT:UseOverride()
	self:EmitSound("buttons/lightswitch2.wav")

	if IsValid(self.stream) then
		self.stream:Stop()
	else
		self:PlayRadio()
	end
end

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

function ENT:OnRemove()
	self:StopRadio()
end

function ENT:Think()
	if IsValid(self.stream) then
		self.stream:SetPos( self:GetPos() )
		self.stream:SetVolume( 1 ) -- its a float
		self.stream:EnableLooping( false )
	end
end

local url = "https://od.lk/s/MjhfNDExNzA5MDhf/tjrtest.mp3"
function ENT:PlayRadio()
	if self.loading == true then return false end
	-- will prevent it from starting multiple streams and therefore screwing up

	self:StopRadio()

	self.loading = true

	sound.PlayURL(url, "noblock 3d", function(station)
		self.loading = false
		if IsValid( station ) then
			station:SetPos( self:GetPos() )
			station:Set3DFadeDistance( 512, 16383 )
			station:Play()
			self.stream = station

			return true
		else
			LocalPlayer():ChatPrint( "[WebRadio]: Failed to start stream: \"" .. url .. "\" !" )
		end
	end)

	return false
end

function ENT:StopRadio()
	if IsValid(self.stream) then
		self.stream:Stop()
	end
end

net.Receive("TraitorJoe_Radio", function()
	local radio
	for _, ent in ents.Iterator() do
		if ent:GetClass() != "tj_radio" then continue end

		radio = ent
		break
	end

	if !IsValid(radio) then return end

	if net.ReadBool() then
		radio:PlayRadio()
	else
		radio:StopRadio()
	end
end)