--Updated Uncurl code by GLide KS
local UNCURL_LOCKTIME = 8

COM_AddCommand("uncurltoggle", function(p, val)
    local no = (val == "0" or val == "no" or val == "off" or val == "false")
    local yes = (val == "1" or val == "yes" or val == "on" or val == "true")

	if not (p and p.valid and p.mo and p.mo.valid) then
		CONS_Printf(p,"This command can only be used inside a level.")
		return
	end

	if no then
		p.uncurltoggle = 0
		CONS_Printf(p,"Uncurl toggle disabled.")
	elseif yes then
		p.uncurltoggle = 1
		CONS_Printf(p,"Uncurl toggle enabled.")
	else
		if p.uncurltoggle == 1 then CONS_Printf(p,"uncurltoggle is on. Default is on.")
        else CONS_Printf(p,"uncurltoggle is off. Default is on.")
		end
	end
end)

local function Uncurl(p)
    if p.uncurltoggle == nil then p.uncurltoggle = 1 end
    if not p.uncurltoggle then return end
    if (p.lastbuttons & BT_SPIN) then return end
    if not (p.pflags & PF_SPINNING) then return end
    local mo = p.mo
    if mo.uncurl_lock then return end
    if not (mo and mo.health) then return end
    if not P_IsObjectOnGround(mo) then return end

    if FixedHypot(mo.momx, mo.momy) >= p.runspeed then
        mo.state = S_PLAY_RUN
	else
		mo.state = S_PLAY_WALK
	end
    p.pflags = $1 & ~PF_SPINNING
    S_StartSound(mo, sfx_s3k52) -- Uncurl sound
    S_StopSoundByID(mo,sfx_spin)
    mo.uncurl_lock = UNCURL_LOCKTIME --avoids excessive spam
    return true
end

local function LockTime(mo)
    if not mo.player then return end
    if not mo.player.uncurltoggle then return end
    if not mo.uncurl_lock then return end
    mo.uncurl_lock = $-1
end

addHook("SpinSpecial", Uncurl)
addHook("MobjThinker", LockTime, MT_PLAYER)