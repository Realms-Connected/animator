export interface BaseAnimation
{
    /*
     * Add an event.
     */
    addEvent(time: number, name: string, limb: unknown, data: Record<string, defined>): void;
    /*
     * Sort registered events by time.
     */
    sortEvents(): void;
    
    length: number;
    keyframeTimes: Array<unknown>;
    poses: Array<unknown>;
    holes: Array<unknown>;
    events: Array<unknown>;
}

/*
 * Build animation from Roblox KeyframeSequence
 */
export const fromKeyframeSequence: (sequence: KeyframeSequence) => BaseAnimation;
