interface Rig
{
	limbs: Record<number, { name: string, parent: string, c0: CFrame, c1: CFrame }>,
	transforms: Record<number, { position: Vector3, quatVec: Vector3, quatW: number, priority: number }>
	output: {
		root: string,
		[key: string]: unknown
	}
}

interface RigConstructor
{
	create: (motor6Ds: Motor6D[]) => Rig
}

declare const Rig: RigConstructor
export = Rig
