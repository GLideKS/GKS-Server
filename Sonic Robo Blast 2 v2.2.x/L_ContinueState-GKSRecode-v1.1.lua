--Continue State script in around 60 lines of code by: GLide KS

freeslot("S_CONTSWITCH")
states[S_CONTSWITCH] = {SPR_PLAY, SPR2_CNT1, 8, nil, nil, nil, S_CONTSWITCH}
local S_CONTSWITCH = S_CONTSWITCH --Optimization reasons

local function ToggleCnt(p) --toggle continue state activation
	if p.togglecntoff then
		p.togglecntoff = false
		CONS_Printf(p, "\x82"+"Continue State Switcher Enabled.")
	else
        if p.mo.state == S_CONTSWITCH then
            if not p.speed then p.mo.state = S_PLAY_STND
            else p.mo.state = S_PLAY_WALK end
            p.mo.continueswitch = false
        end
        p.togglecntoff = true
        CONS_Printf(p, "\x86"+"Continue State Switcher Disabled.")
	end
end
COM_AddCommand("togglecnt", ToggleCnt)
COM_AddCommand("togglecnt2", ToggleCnt, COM_SPLITSCREEN) --for Player 2

local DoingSomething = function(p)
    if (p.pflags & (PF_JUMPED|PF_THOKKED|PF_SPINNING))
    or p.powers[pw_carry]
    or (p.mo.eflags & MFE_SPRUNG) then
        return true
    end
end

local BTN = BT_FIRENORMAL --button to press
local switch = function(p)
    if p.togglecntoff then return end --End the function completely if continue switch is off
    if (gametyperules & GTR_RINGSLINGER) then return end --Do not run this on ringslinger
    if not (p.mo and p.mo.valid and (p.mo.health or p.playerstate & PST_LIVE)) then return end --Is the player even alive
    local mo = p.mo

    if not P_IsObjectOnGround(mo)  --Is the player in the air? switch to fall frames
    and mo.state == S_CONTSWITCH then
        mo.state = S_PLAY_FALL
        return
    end

    if mo.state == S_CONTSWITCH then p.powers[pw_nocontrol] = -1 end --Disable player control on this state

    --Do not run the following code if the player is not pressing the button
    if DoingSomething(p) then return end
    if not ((p.cmd.buttons & BTN) and not (p.lastbuttons & BTN)) then return end

    if mo.state != S_CONTSWITCH then mo.state = S_CONTSWITCH
    else
        if not p.speed then mo.state = S_PLAY_STND
        else mo.state = S_PLAY_WALK end
    end
end
addHook("PlayerThink", switch)