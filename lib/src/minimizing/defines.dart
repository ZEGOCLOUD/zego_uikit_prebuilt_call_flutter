/// The current state of the minimized interface can be described as follows:
///
/// [idle]: in a blank state, not yet minimized, or has been restored to the original Widget.
/// [calling]: in the process of being restored from the minimized state.
/// [minimizing]: in the minimized state.
enum ZegoCallMiniOverlayPageState {
  idle,
  calling,
  minimizing,
}
