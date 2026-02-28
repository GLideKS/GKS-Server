local baseCoyoteTime = TICRATE/4
local P_IsObjectOnGround = P_IsObjectOnGround
local P_InQuicksand = P_InQuicksand
local P_DoJump = P_DoJump
local P_PlayerInPain = P_PlayerInPain
local P_GetMobjGravity = P_GetMobjGravity
local abs = abs
local max = max
local FixedFloor = FixedFloor
local FixedDiv = FixedDiv
local PF_JUMPED = PF_JUMPED
local PF_THOKKED = PF_THOKKED
local PF_JUMPSTASIS = PF_JUMPSTASIS
local pw_carry = pw_carry
local pw_justsprung = pw_justsprung
local pw_nocontrol = pw_nocontrol
local BT_JUMP = BT_JUMP
local FRACUNIT = FRACUNIT
local FRACBITS = FRACBITS
local painThrust = 69*FRACUNIT/10

local function CoyoteJump(p)
    local mo = p.mo
    local button = p.cmd.buttons

    -- Check if you're in a state where you would normally be allowed to jump.
	local canJump = false;
	if(P_IsObjectOnGround(mo) or P_InQuicksand(mo))
	and not p.powers[pw_carry] then
		if not canJump then canJump = true end
	end

    if (p.pflags & PF_JUMPED) or (p.powers[pw_justsprung]) then
		-- We jumped. We should not have coyote time.
		if mo.coyoteTime then mo.coyoteTime = 0 return end
    elseif canJump then
        if not mo.coyoteTime then mo.coyoteTime = baseCoyoteTime + p.cmd.latency end
    else
        if ((button & BT_JUMP) and not (p.lastbuttons & BT_JUMP))
        and mo.coyoteTime then
            P_DoJump(p, true)
            p.pflags = $ & ~PF_THOKKED
            if p.mo.coyoteTime then p.mo.coyoteTime = 0 end
            return
        end
        -- Reduce coyote timer while in a state where you can't jump.
        if (mo.coyoteTime and mo.coyoteTime > 0) then mo.coyoteTime = $ - 1 end
    end
end

local function RecoveryJump(p)
    local mo = p.mo
    local buttons = p.cmd.buttons
    local latency = p.cmd.latency

    if mo.recoveryWait == nil then mo.recoveryWait = 0 end

    if not P_PlayerInPain(p)
    or P_IsObjectOnGround(mo) then
        if mo.recoveryWait then mo.recoveryWait = 0 end
        return
    end

    if mo.coyoteTime then mo.coyoteTime = 0 end

    mo.recoveryWait = $+1
    if ((buttons & BT_JUMP) and not (p.lastbuttons & BT_JUMP)) then
		local baseGravity = max(1, abs(P_GetMobjGravity(mo)));
		local painTime = FixedFloor(FixedDiv(painThrust, baseGravity)) >> FRACBITS;
		local baseRecoveryWait = (painTime * 2); -- Double the length of your pain state, - your latency.}

		if (mo.recoveryWait > baseRecoveryWait - latency) then
            P_DoJump(p, true)
            p.pflags = $ & ~PF_THOKKED
            if mo.recoveryWait then mo.recoveryWait = 0 end
            return
        end
    end
end

local function PThink(p)
    local mo = p.mo
    if (mapheaderinfo[gamemap].jumpleniency) then return end
    if p.exiting then return end
    if p.powers[pw_nocontrol] then return end
    if (p.pflags & PF_JUMPSTASIS) then return end
    if not (mo and mo.valid) then return end
    if not mo.health then return end
    CoyoteJump(p)
    RecoveryJump(p)
end

addHook("PlayerThink", PThink)