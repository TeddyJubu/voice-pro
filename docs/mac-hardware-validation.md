# Mac Hardware Validation

Use this checklist to separate validation that can be completed in cloud CI from validation that must be executed on physical macOS hardware.

## Cloud-complete (CI-safe)

- [ ] Lint, format, and static analysis pass.
- [ ] Unit tests pass for audio pipeline modules with mocked devices.
- [ ] Integration tests pass for API boundaries (without live microphone/speaker).
- [ ] Moonshine and Silero model load smoke tests pass in CPU-only CI.
- [ ] Pocket TTS text-to-audio generation test produces non-empty waveform artifacts.
- [ ] Hotkey registration logic tests pass with OS hook interfaces mocked.
- [ ] End-to-end pipeline tests pass in simulated time with deterministic fixtures.
- [ ] Regression tests for wake word/transcript/intent routing pass using prerecorded inputs.

## Mac-required validation

> These checks **cannot** be marked done in cloud-only environments. They require local execution on macOS with real hardware and user-level permissions.

### 1) Mic capture (real input path)

- [ ] **Validation method:**
  - Launch the app on macOS and select the target physical microphone.
  - Record at least three utterances in quiet and mildly noisy conditions.
  - Verify captured waveform/transcript in logs or debug UI.
- [ ] **Success criteria:**
  - Input device is detected and selectable without fallback errors.
  - Speech is captured without clipping/dropouts for all test utterances.
  - Transcript confidence/quality is acceptable for expected commands.
- [ ] **Required hardware/environment notes:**
  - Physical Mac with an internal or USB microphone.
  - macOS microphone permission granted for the app/terminal.
  - Quiet room plus one noisy-condition pass for robustness.

### 2) Speaker playback (real output path)

- [ ] **Validation method:**
  - Trigger representative TTS or response playback flows.
  - Test through built-in speakers and (if supported) Bluetooth/USB headset.
  - Observe system output device changes while app is running.
- [ ] **Success criteria:**
  - Audio is audible, free from severe artifacts, and routed to the selected output.
  - Device switching does not crash or permanently mute playback.
  - No sustained stutter beyond brief transition effects.
- [ ] **Required hardware/environment notes:**
  - Physical Mac with working speakers.
  - Optional external headset/speaker for route-switch checks.
  - macOS sound output controls accessible to tester.

### 3) Moonshine/Silero runtime (on-device behavior)

- [ ] **Validation method:**
  - Run realtime inference sessions with live mic input for both runtimes.
  - Capture CPU/memory metrics during short (1-2 min) and long (10+ min) runs.
  - Compare runtime logs for model initialization and fallback behavior.
- [ ] **Success criteria:**
  - Both runtimes initialize successfully on macOS target architecture.
  - Realtime inference remains stable with no fatal runtime/model errors.
  - Resource usage stays within agreed operational budget.
- [ ] **Required hardware/environment notes:**
  - Physical Mac matching supported chips (Apple Silicon and/or Intel target matrix).
  - Local model artifacts available and readable on disk.
  - Consistent power mode (battery vs plugged-in) documented in test notes.

### 4) Pocket TTS audio quality (human-perceived quality)

- [ ] **Validation method:**
  - Generate a fixed prompt set (short, long, numbers, names, punctuation-heavy).
  - Perform human listening pass with at least one additional reviewer when possible.
  - Optionally compare against prior release samples.
- [ ] **Success criteria:**
  - Speech is intelligible and natural enough for product baseline.
  - No major glitches (pops, truncation, repeated phonemes) in prompt set.
  - Pronunciation for key product/domain terms meets acceptance baseline.
- [ ] **Required hardware/environment notes:**
  - Physical Mac with reliable playback device (speakers or quality headset).
  - Quiet listening environment.
  - Fixed reference prompt list/version controlled with release notes.

### 5) Hotkey permissions (macOS privacy/AX integration)

- [ ] **Validation method:**
  - Start from a clean or reset permission state when feasible.
  - Register global hotkey and exercise key-down/key-up interactions.
  - Validate permission prompts and post-grant behavior.
- [ ] **Success criteria:**
  - App surfaces clear guidance when Accessibility/Input Monitoring is missing.
  - After granting permission, hotkeys trigger reliably across target apps.
  - Permission revocation is handled gracefully with actionable error state.
- [ ] **Required hardware/environment notes:**
  - Physical Mac with user account allowed to manage Privacy & Security settings.
  - macOS Accessibility/Input Monitoring controls available.
  - External keyboard optional but recommended for key rollover edge cases.

### 6) End-to-end latency (capture -> inference -> response playback)

- [ ] **Validation method:**
  - Measure latency from start-of-speech (or hotkey trigger) to first audible response.
  - Run repeated trials (minimum 20) across at least two network conditions if cloud services are involved.
  - Record p50/p95 and worst-case latency.
- [ ] **Success criteria:**
  - Median and tail latency meet product SLA/UX targets.
  - No pathological outliers that break turn-taking experience.
  - Latency remains within tolerance after warm-up and during extended session.
- [ ] **Required hardware/environment notes:**
  - Physical Mac with stable clock/time sync.
  - Consistent audio hardware path for all trials.
  - Documented network profile (wired/wifi, bandwidth, jitter) when applicable.
