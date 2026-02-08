import Animation from "./Animation";
import Blend from "./Blend";
import Rig from "./Rig";

interface Solver
{
    solve: (
        rig: ReturnType<(typeof Rig)["create"]>,
        tracks: Map<ReturnType<typeof Animation["fromKeyframeSequence"]>, Blend.BlendTrack>,
        targetCharacterCFrame: CFrame
    ) => void;
}

declare const Solver: Solver;
export = Solver;
