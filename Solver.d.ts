import Animation from "./Animation";
import Blend from "./Blend";
import Rig from "./Rig";

interface Solver
{
    solve: (
        rig: ReturnType<(typeof Rig)["create"]>,
        tracks: Map<ReturnType<(typeof Animation)["fromKeyframeSequence"]>, ReturnType<(typeof Blend)["blend"]>>,
    ) => void;
}

declare const x: Solver;
