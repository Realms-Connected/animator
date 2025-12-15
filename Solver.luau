local Math = require(script.Parent.Math)
local Solver = {}

local function findKeyframeIndex(times, t)
	local low, high = 1, #times - 1
	while low <= high do
		local mid = (low + high) // 2
		if times[mid] <= t and t < times[mid + 1] then
			return mid
		elseif t < times[mid] then
			high = mid - 1
		else
			low = mid + 1
		end
	end
	return math.clamp(low, 1, #times - 1)
end

local function preprocessEvents(anim)
	if anim._eventsProcessed then return end
	anim._eventsProcessed = true
	anim._perLimbEvents = {}
	anim._globalEvents = {}

	if anim.events then
		for _, event in ipairs(anim.events) do
			if event.limb then
				local list = anim._perLimbEvents[event.limb]
				if not list then
					list = {}
					anim._perLimbEvents[event.limb] = list
				end
				list[#list+1] = event
			else
				anim._globalEvents[#anim._globalEvents + 1] = event
			end
		end
	end

	local function sortEvents(list)
		table.sort(list, function(a,b) return a.time < b.time end)
	end

	sortEvents(anim._globalEvents)
	for _, list in pairs(anim._perLimbEvents) do
		sortEvents(list)
	end
end

local function triggerEvents(track, eventsList, lastTime, time, anim)
	if not eventsList or #eventsList == 0 then return end
	track._eventIndex = track._eventIndex or {}
	local idx = track._eventIndex[eventsList] or 1

	while idx <= #eventsList do
		local e = eventsList[idx]
		local fire = false
		if time >= lastTime then
			fire = lastTime < e.time and time >= e.time
		else
			fire = e.time > lastTime or e.time <= time
		end

		if fire then
			if track.onEvent then
				track.onEvent(e.name, e.time, e.data, anim, e.limb)
			end
			idx += 1
		else
			break
		end
	end

	if time < lastTime then
		idx = 1
	end
	track._eventIndex[eventsList] = idx
end

local function quatToCFrame(qv, qw)
	local x, y, z = qv.X or 0, qv.Y or 0, qv.Z or 0
	local w = qw or 1

	local xx, yy, zz = x*x, y*y, z*z
	local xy, xz, yz = x*y, x*z, y*z
	local wx, wy, wz = w*x, w*y, w*z

	local m00 = 1 - 2*(yy + zz)
	local m01 = 2*(xy - wz)
	local m02 = 2*(xz + wy)

	local m10 = 2*(xy + wz)
	local m11 = 1 - 2*(xx + zz)
	local m12 = 2*(yz - wx)

	local m20 = 2*(xz - wy)
	local m21 = 2*(yz + wx)
	local m22 = 1 - 2*(xx + yy)

	return CFrame.new(0, 0, 0, m00, m01, m02, m10, m11, m12, m20, m21, m22)
end

local function interpolateLimb(limbState, anim, i, frameIndex, time, track, influence, priority)
	local hole = anim.holes[i]
	local leftIndex = hole and hole[frameIndex][1] or frameIndex
	local rightIndex = hole and hole[frameIndex][2] or frameIndex + 1
	local poseA = anim.poses[leftIndex] and anim.poses[leftIndex][i]
	local poseB = anim.poses[rightIndex] and anim.poses[rightIndex][i]

	if not poseA then return end

	local tInterp = 0
	if poseB and anim.keyframeTimes[rightIndex] and anim.keyframeTimes[leftIndex] then
		tInterp = (time - anim.keyframeTimes[leftIndex]) / math.max(anim.keyframeTimes[rightIndex] - anim.keyframeTimes[leftIndex], 1e-5)
		tInterp = poseA.easing and poseA.easing(math.clamp(tInterp, 0, 1)) or math.clamp(tInterp, 0, 1)
	end

	local samplePos = poseB and poseA.position:Lerp(poseB.position, tInterp) or poseA.position
	local sampleQV, sampleQW = poseA.quatVec or Vector3.zero, poseA.quatW or 1
	if poseB and Math.nlerpQuat then
		sampleQV, sampleQW = Math.nlerpQuat(poseA.quatVec or Vector3.zero, poseA.quatW or 1, poseB.quatVec or Vector3.zero, poseB.quatW or 1, tInterp)
	end

	if track.additive then
		limbState.position += samplePos * influence
		local dqv, dqw = Math.nlerpQuat and Math.nlerpQuat(Vector3.zero, 1, sampleQV, sampleQW, influence) or sampleQV, sampleQW
		if Math.mulQuat then
			limbState.quatVec, limbState.quatW = Math.mulQuat(limbState.quatVec, limbState.quatW, dqv, dqw)
		else
			limbState.quatVec, limbState.quatW = dqv, dqw
		end
	else
		limbState.position = limbState.position:Lerp(samplePos, influence)
		if Math.nlerpQuat then
			limbState.quatVec, limbState.quatW = Math.nlerpQuat(limbState.quatVec, limbState.quatW, sampleQV, sampleQW, influence)
		else
			limbState.quatVec, limbState.quatW = sampleQV, sampleQW
		end
		limbState.priority = priority
	end
end

function Solver.solve(rig, tracks, rootCFrame)
	for _, t in ipairs(rig.transforms) do
		t.priority = -1
	end

	local totalWeight = 0
	for _, track in pairs(tracks) do
		if not track.additive then
			totalWeight += track.weight or 0
		end
	end
	if totalWeight <= 0 then totalWeight = 1 end

	for anim, track in pairs(tracks) do
		preprocessEvents(anim)

		local priority = track.priority or 0
		local alpha = math.clamp(track.alpha or 0, 0, 1)
		local time = anim.length * alpha
		local fade = Math.fade(time, anim.length, track.startFade or 0, track.stopFade or 0)
		local weight = track.weight or 0
		local influence = track.additive and (weight * fade) or ((weight / totalWeight) * fade)
		if influence <= 0 then continue end

		local frameIndex = findKeyframeIndex(anim.keyframeTimes, time)

		for i, limbState in ipairs(rig.transforms) do
			if track.additive or limbState.priority <= priority then
				interpolateLimb(limbState, anim, i, frameIndex, time, track, influence, priority)
			end
		end

		if track.onEvent then
			track._lastTime = track._lastTime or 0
			local lastTime = track._lastTime
			triggerEvents(track, anim._globalEvents, lastTime, time, anim)
			for _, eventsList in pairs(anim._perLimbEvents) do
				triggerEvents(track, eventsList, lastTime, time, anim)
			end
			track._lastTime = time
		end
	end

	rig.output["root"] = rootCFrame or CFrame.identity
	for i, limb in ipairs(rig.limbs) do
		local t = rig.transforms[i]
		rig.output[limb.name] =
			(rig.output[limb.parent] or CFrame.identity) *
			(limb.c0 or CFrame.identity) *
			quatToCFrame(t.quatVec, t.quatW) *
			(limb.c1 or CFrame.identity)
	end
end

return Solver
