interface Animation {
	/*
	 * Add an event.
	 */
	addEvent(time: number, name: string, limb: unknown, data: Record<string, defined>): void
	/*
	 * Sort registered events by time.
	 */
	sortEvents(): void,
}

declare interface AnimationConstructor {
	/*
	* Build animation from Roblox KeyframeSequence
	*/
	fromKeyframeSequence: (sequence: KeyframeSequence) => Animation
}

declare const Animation: AnimationConstructor;
export = Animation;
