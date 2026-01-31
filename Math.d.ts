interface Math {
	nlerpQuat: (aVec: Vector3, aW: number, bVec: Vector3, bW: number, t: number) => LuaTuple<[Vector3, number]>
	/**
	* Spherical linear quaternion interpolation (aka: SLERP).
	* Smooth interpolation along the shortest path on the quaternion sphere.
	*/
	slerpQuat: (aVec: Vector3, aW: number, bVec: Vector3, bW: number, t: number) => LuaTuple<[Vector3, number]>
	/* Fade function for animation tracks.
	* Returns alpha value based on fadeIn/fadeOut times.
	*/
	fade: (time: number, length: number, fadeIn: number, fadeOut: number) => number
	/*
	* Multiply two quaternions using the Hamilton product.
	*/
	mulQuat: (aVec: Vector3, aW: number, bVec: Vector3, bW: number) => LuaTuple<[Vector3, number]>
	/*
	 * Normalize a quaternion.
	 */
	normalizeQuat: (qVec: Vector3, qW: number) => LuaTuple<[Vector3, number]>
}

declare const Math: Math
export = Math;

