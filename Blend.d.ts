import { BaseAnimation } from "lib/animation/animator/Animation";

export interface BlendTrackOptions {
    alpha: number,
    weight: number,
    priority: number,
    startFade: number,
    stopFade: number,
}
export interface BlendTrack extends BlendTrackOptions
{
    animation: BaseAnimation,
}


/*
 * Creates a track table.
 * @param {BaseAnimation} anim The animation object.
 * @param options A table with optional fields: `alpha`, `weight`, `priority`, `startFade`, `stopFade`.
 */
export const track: (
    animation: BaseAnimation,
    options?: Partial<BlendTrackOptions>,
) => BlendTrack

/**
 * Crossfade between two animations over a given duration.
 */
export const crossfade: (
    fromAnim: BaseAnimation,
    toAnim: BaseAnimation,
    duration: number,
    priority?: number,
) => Map<BaseAnimation, Omit<BlendTrack, "startFade"> | Omit<BlendTrack, "stopFade">>;

/**
 * Blend two animations by a normalized weight.
 * @param {number} weight A fraction of AnimB (0: full AnimA, 1: full AnimB).
 */
export const blend: (
    animA: BaseAnimation,
    animB: BaseAnimation,
    weight: number,
    priority?: number,
) => Map<BaseAnimation, Pick<BlendTrack, "alpha" | "weight" | "priority">>;

/**
 * Snap an animation instantly (no fade).
 */
export const snap: (
    anim: BaseAnimation,
    priority?: number,
) => Map<BaseAnimation, Omit<BlendTrack, "animation">>;

/**
 * Additive layer.
 * @param {number} weight The absolute influence of an additive animation.
 */
export const additive: (
    anim: BaseAnimation,
    weight: number,
    priority?: number,
) => Map<BaseAnimation, Omit<BlendTrack, "animation">>;
