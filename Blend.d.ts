interface Blend
{
    /*
     * Creates a track table.
     * @param {Animation} anim The animation object.
     * @param options A table with optional fields: `alpha`, `weight`, `priority`, `startFade`, `stopFade`.
     */
    track: (
        animation: Animation,
        options: Partial<{
            animation: Animation,
            alpha: number,
            priority: number,
            startFade: number,
            stopFade: number,
        }>,
    ) => Required<typeof options>;

    /**
     * Crossfade between two animations over a given duration.
     */
    crossfade: (
        fromAnim: Animation,
        toAnim: Animation,
        duration: number,
        priority?: number,
    ) => Map<Animation, { alpha: number, weight: number, priority: number, stopFade: number }>;

    /**
     * Blend two animations by a normalized weight.
     * @param {number} weight A fraction of AnimB (0: full AnimA, 1: full AnimB).
     */
    blend: (
        animA: Animation,
        animB: Animation,
        weight: number,
        priority?: number,
    ) => Map<Animation, { alpha: number, weight: number, priority: number }>;

    /**
     * Snap an animation instantly (no fade).
     */
    snap: (
        anim: Animation,
        priority?: number,
    ) => Map<Animation, { alpha: number, weight: number, priority: number, startFade: number, stopFade: number }>;

    /**
     * Additive layer.
     * @param {number} weight The absolute influence of an additive animation.
     */
    additive: (
        anim: Animation,
        weight: number,
        priority?: number,
    ) => Map<Animation, { alpha: number, weight: number, priority: number, additive: true }>;
}
