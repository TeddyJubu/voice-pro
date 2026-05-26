# Benchmark and Execution Event Schemas

This document defines JSON schemas for CLI bridge execution and latency tracing events.

## Global redaction policy (applies to all schemas)

- **Never log secrets, tokens, or raw credentials** in any field.
- Truncate and sanitize command output before logging.
- Replace sensitive matches with `"[REDACTED]"` and set `redaction_applied: true`.

## CLI bridge execution event schema

### Purpose

Captures execution metadata and safety controls for command dispatch through a CLI bridge.

### JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/schemas/cli-bridge-execution-event.json",
  "title": "CliBridgeExecutionEvent",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "event_type",
    "event_id",
    "timestamp",
    "allowlist_key",
    "timeout_ms",
    "cwd_policy",
    "stdout",
    "stderr",
    "exit_code"
  ],
  "properties": {
    "event_type": { "const": "cli_bridge_execution" },
    "event_id": { "type": "string", "minLength": 1 },
    "timestamp": { "type": "string", "format": "date-time" },
    "allowlist_key": {
      "type": "string",
      "minLength": 1,
      "description": "Identifier for the matched allowlisted command pattern."
    },
    "timeout_ms": { "type": "integer", "minimum": 1 },
    "cwd_policy": {
      "type": "object",
      "additionalProperties": false,
      "required": ["mode"],
      "properties": {
        "mode": { "type": "string", "enum": ["fixed", "repo_root", "caller_provided", "restricted"] },
        "resolved_cwd": { "type": "string" }
      }
    },
    "stdout": {
      "type": "object",
      "additionalProperties": false,
      "required": ["bytes_captured", "bytes_logged", "truncated"],
      "properties": {
        "bytes_captured": { "type": "integer", "minimum": 0 },
        "bytes_logged": { "type": "integer", "minimum": 0 },
        "truncated": { "type": "boolean" },
        "preview": { "type": "string" }
      }
    },
    "stderr": {
      "type": "object",
      "additionalProperties": false,
      "required": ["bytes_captured", "bytes_logged", "truncated"],
      "properties": {
        "bytes_captured": { "type": "integer", "minimum": 0 },
        "bytes_logged": { "type": "integer", "minimum": 0 },
        "truncated": { "type": "boolean" },
        "preview": { "type": "string" }
      }
    },
    "exit_code": { "type": "integer" },
    "redaction_applied": { "type": "boolean", "default": false }
  }
}
```

### Field requirements summary

- **Required:** `event_type`, `event_id`, `timestamp`, `allowlist_key`, `timeout_ms`, `cwd_policy`, `stdout`, `stderr`, `exit_code`
- **Optional:** `redaction_applied`

### Logging rules

- `preview` fields must be truncated to a safe maximum length.
- Never include full command output when it may contain secrets.
- `resolved_cwd` must not include user-home secrets or credential file contents.

## Latency trace event schema

### Purpose

Captures per-phase timing points and derived duration totals for benchmarking.

### JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/schemas/latency-trace-event.json",
  "title": "LatencyTraceEvent",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "event_type",
    "event_id",
    "timestamp",
    "trace_id",
    "phases",
    "totals"
  ],
  "properties": {
    "event_type": { "const": "latency_trace" },
    "event_id": { "type": "string", "minLength": 1 },
    "timestamp": { "type": "string", "format": "date-time" },
    "trace_id": { "type": "string", "minLength": 1 },
    "phases": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["name", "start_ts", "end_ts", "duration_ms"],
        "properties": {
          "name": { "type": "string", "minLength": 1 },
          "start_ts": { "type": "string", "format": "date-time" },
          "end_ts": { "type": "string", "format": "date-time" },
          "duration_ms": { "type": "integer", "minimum": 0 }
        }
      }
    },
    "totals": {
      "type": "object",
      "additionalProperties": false,
      "required": ["wall_clock_ms", "phases_sum_ms", "overhead_ms"],
      "properties": {
        "wall_clock_ms": { "type": "integer", "minimum": 0 },
        "phases_sum_ms": { "type": "integer", "minimum": 0 },
        "overhead_ms": { "type": "integer", "minimum": 0 }
      }
    },
    "redaction_applied": { "type": "boolean", "default": false }
  }
}
```

### Field requirements summary

- **Required:** `event_type`, `event_id`, `timestamp`, `trace_id`, `phases`, `totals`
- **Optional:** `redaction_applied`

### Logging rules

- Phase names should be controlled vocabulary where possible.
- Derived totals should be computed from trusted timestamps, not user input.
- Do not embed request payloads in phase metadata.
