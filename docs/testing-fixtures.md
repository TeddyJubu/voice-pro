# Testing Fixtures

This document standardizes test fixtures used across subsystems and defines where fixtures live under `Tests/fixtures/`.

## Scope and goals

Fixtures should make tests deterministic, fast, and readable.

All tests that use these fixtures **must**:

- Avoid real network access.
- Avoid wall-clock timing dependencies (no sleeps/timeouts based on elapsed real time).
- Use controlled clocks, deterministic schedulers, or explicit event driving where timing behavior is needed.

## Fixture root layout

All fixtures live under:

- `Tests/fixtures/voice-cerebras/`
- `Tests/fixtures/voice-core/`
- `Tests/fixtures/voice-security/`
- `Tests/fixtures/voice-mcp/`

Recommended shared subfolders within each subsystem:

- `inputs/` for request/event/input payloads
- `outputs/` for expected decoded/model outputs
- `errors/` for malformed/invalid payloads
- `goldens/` for snapshot-style expected results

## Naming conventions

Use lowercase kebab-case for fixture file names with this pattern:

`<subsystem>-<scenario>-<variant>.<ext>`

Where:

- `<subsystem>` is one of: `cerebras`, `core`, `security`, `mcp`
- `<scenario>` describes behavior under test (for example `sse-normal`, `path-traversal`)
- `<variant>` distinguishes data shapes or versions (for example `v1`, `short`, `multiturn`)

Examples:

- `cerebras-sse-normal-v1.jsonl`
- `cerebras-sse-malformed-missing-data.jsonl`
- `core-pipeline-happy-path-v1.json`
- `security-injection-shell-quoted-v1.json`
- `mcp-call-invalid-tool-name-v1.json`

Additional conventions:

- Prefer `.json`/`.jsonl`/`.txt` for human-readable fixtures.
- Keep one semantic case per file; do not combine unrelated scenarios.
- Include a brief header comment in text-based fixtures when format permits.

## Subsystem fixture requirements

### `VoiceCerebrasTests`

Store in `Tests/fixtures/voice-cerebras/`.

Required fixture scenarios:

1. **SSE normal streaming**
   - Ordered events forming a complete response.
   - Includes start/chunk/end patterns.
2. **SSE partial streaming**
   - Truncated stream and/or missing terminal event.
   - Validates graceful partial decode behavior.
3. **SSE malformed payloads**
   - Bad JSON, missing `data:` prefix, invalid event framing.
   - Validates parser error handling.
4. **SSE cancellation**
   - Cancellation mid-stream with expected cleanup sequence.
   - Verifies no post-cancel emission.

Suggested files:

- `Tests/fixtures/voice-cerebras/inputs/cerebras-sse-normal-v1.jsonl`
- `Tests/fixtures/voice-cerebras/inputs/cerebras-sse-partial-v1.jsonl`
- `Tests/fixtures/voice-cerebras/errors/cerebras-sse-malformed-bad-json-v1.jsonl`
- `Tests/fixtures/voice-cerebras/inputs/cerebras-sse-cancel-midstream-v1.jsonl`

### `VoiceCoreTests`

Store in `Tests/fixtures/voice-core/`.

Required fixture scenarios:

- Fake audio input that drives the full pipeline:
  - VAD segmentation
  - ASR transcript generation
  - LLM response generation
  - TTS output generation

Fixtures should include both input media metadata and expected intermediate artifacts for each stage.

Suggested files:

- `Tests/fixtures/voice-core/inputs/core-audio-fake-happy-path-v1.json`
- `Tests/fixtures/voice-core/outputs/core-vad-segments-happy-path-v1.json`
- `Tests/fixtures/voice-core/outputs/core-asr-transcript-happy-path-v1.json`
- `Tests/fixtures/voice-core/outputs/core-llm-response-happy-path-v1.json`
- `Tests/fixtures/voice-core/outputs/core-tts-output-happy-path-v1.json`

### `VoiceSecurityTests`

Store in `Tests/fixtures/voice-security/`.

Required fixture scenarios:

1. **Injection attempts**
   - Prompt injection, shell injection, and argument injection payloads.
2. **Path traversal attempts**
   - Relative traversal (`../`), encoded traversal, mixed separator variants.
3. **Destructive command attempts**
   - Commands that should be blocked/sanitized in all execution contexts.

Suggested files:

- `Tests/fixtures/voice-security/inputs/security-injection-prompt-basic-v1.json`
- `Tests/fixtures/voice-security/inputs/security-injection-shell-basic-v1.json`
- `Tests/fixtures/voice-security/inputs/security-path-traversal-relative-v1.json`
- `Tests/fixtures/voice-security/inputs/security-path-traversal-encoded-v1.json`
- `Tests/fixtures/voice-security/inputs/security-destructive-command-rmrf-v1.json`

### `VoiceMCPTests`

Store in `Tests/fixtures/voice-mcp/`.

Required fixture scenarios:

1. **Initialize handshake fixtures**
2. **List tools/resources fixtures**
3. **Call tool fixtures** (valid tool invocation)
4. **Invalid tool fixtures** (unknown tool, bad args schema, bad method)

Suggested files:

- `Tests/fixtures/voice-mcp/inputs/mcp-initialize-request-v1.json`
- `Tests/fixtures/voice-mcp/outputs/mcp-initialize-response-v1.json`
- `Tests/fixtures/voice-mcp/inputs/mcp-list-tools-request-v1.json`
- `Tests/fixtures/voice-mcp/outputs/mcp-list-tools-response-v1.json`
- `Tests/fixtures/voice-mcp/inputs/mcp-call-valid-echo-v1.json`
- `Tests/fixtures/voice-mcp/errors/mcp-call-invalid-tool-v1.json`
- `Tests/fixtures/voice-mcp/errors/mcp-call-invalid-args-v1.json`

## Determinism requirements for tests

When using these fixtures, tests should be deterministic by construction:

- Replace network clients with mocks/stubs/fakes.
- Replace wall-clock reads (`Date`, `Clock`, timers) with injected fake clocks.
- Assert on explicit events/messages, not elapsed time windows.
- Ensure fixture decoding/parsing does not depend on locale or environment-specific settings.

If timing behavior must be validated, drive the scheduler/clock explicitly from the test.
