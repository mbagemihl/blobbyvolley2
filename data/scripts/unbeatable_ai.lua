-- Unbeatable AI for Blobby Volley 2 Time-Survival Mode
-- Uses C++ PhysicWorld trajectory simulation (estimate_x_at_y / simulate_until)
-- with 2x horizontal speed support on the right side.

modeLock = false
timeto = 0
target = 0
naivetarget = 0
estimbspeedx = 0
servrand = nil

local BOT_SPEED = CONST_BLOBBY_SPEED * 2.0

local function fast_moveto(dest)
	if dest == nil then
		return false
	end
	local x = posx()
	if x < dest - BOT_SPEED / 2 then
		right()
		return false
	elseif x > dest + BOT_SPEED / 2 then
		left()
		return false
	else
		__WANT_LEFT  = false
		__WANT_RIGHT = false
		return true
	end
end

function OnServe(ballready)
	if servrand == nil then
		servrand = math.random()
	end

	if fast_moveto(ballx() + servrand * 5) and ballready then
		jump()
		servrand = nil
	end
end

function OnOpponentServe()
	fast_moveto(130)
end

function OnGame()
	-- Try high offensive/return play when reachable
	if estimImpactHigh() then
		if naivetarget < CONST_FIELD_MIDDLE and target < CONST_FIELD_MIDDLE
			and (modeLock == true or timeto > math.abs(posx() - highPlayPos()) / BOT_SPEED + 24)
			and touches() < 3
		then
			modeLock = timeto < 28
			if modeLock == false then
				servrand = nil
			end
			highPlay()
			return
		end
	end

	modeLock = false
	servrand = nil

	if estimImpactLow() then
		if target < CONST_FIELD_MIDDLE then
			-- Position slightly behind the ball (smaller x in mirrored bot coords) so the ball always flies over the net
			local interceptX = math.max(CONST_BALL_LEFT_BORDER, target - 12)
			fast_moveto(interceptX)
			if timeto < 8 and math.abs(posx() - interceptX) < 28 and bally() < CONST_BLOBBY_MAX_JUMP then
				jump()
			end
		else
			fast_moveto(130)
		end
	else
		fast_moveto(130)
	end
end

function highPlayPos()
	if estimbspeedx < 0 then
		return target - 42 - estimbspeedx * 4
	else
		return target - 42
	end
end

function highPlay()
	if target > CONST_FIELD_MIDDLE then
		fast_moveto(130)
	else
		fast_moveto(highPlayPos())
		if servrand == nil then
			servrand = math.random()
		end
		if naivetarget < CONST_FIELD_MIDDLE and timeto < 28 + servrand then
			jump()
		end
	end
end

function estimImpactHigh()
	return estimImpact(CONST_BLOBBY_MAX_JUMP - 25)
end

function estimImpactLow()
	return estimImpact(CONST_BALL_BLOBBY_HEAD)
end

function estimImpact(destY)
	local x, v, t = estimate_x_at_y(destY)
	if t == math.huge or t < 0 then
		target = nil
		return false
	end

	naivetarget = (bspeedx() * t) + ballx()
	target, estimbspeedx, timeto = x, v, t
	return true
end
