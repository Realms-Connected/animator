-- ReplicatedStorage/MyAnimator/Blend.lua

local Blend = {}

-- Creates a track table
-- anim: Animation object
-- options: table with optional fields: alpha, weight, priority, startFade, stopFade
function Blend.track(anim, options)
	options = options or {}
	return {
		animation = anim,
		alpha = options.alpha or 0,
		weight = options.weight or 1,
		priority = options.priority or 0,
		startFade = options.startFade or 0,
		stopFade = options.stopFade or 0,
	}
end

-- Crossfade between two animations over a given duration
-- fromAnim -> toAnim
function Blend.crossfade(fromAnim, toAnim, duration, priority)
	priority = priority or 0
	return {
		[fromAnim] = {
			alpha = 1,
			weight = 1,
			priority = priority,
			stopFade = duration,
		},
		[toAnim] = {
			alpha = 0,
			weight = 1,
			priority = priority,
			startFade = duration,
		},
	}
end

-- Blend two animations by a normalized weight
-- weight: fraction of animB (0 = full animA, 1 = full animB)
function Blend.blend(animA, animB, weight, priority)
	priority = priority or 0
	return {
		[animA] = {
			alpha = 1,
			weight = 1 - weight, -- relative weight
			priority = priority,
		},
		[animB] = {
			alpha = 1,
			weight = weight,
			priority = priority,
		},
	}
end

-- Snap an animation instantly (no fade)
function Blend.snap(anim, priority)
	priority = priority or 0
	return {
		[anim] = {
			alpha = 1,
			weight = 1,
			priority = priority,
			startFade = 0,
			stopFade = 0,
		},
	}
end

-- Additive layer
-- weight: absolute influence of additive animation
function Blend.additive(anim, weight, priority)
	priority = priority or 0
	return {
		[anim] = {
			alpha = 1,
			weight = weight or 1,
			priority = priority,
			additive = true,
		}
	}
end

-- Optional: helper function to apply crossfade over time (not required)
-- Could be added in the future as Blend.applyCrossfade(trackTable, deltaTime)

return Blend
