# Security Event Schemas

This document defines JSON schemas and logging rules for security-sensitive audit events.

## Global redaction policy (applies to all schemas)

- **Never log secrets, tokens, or raw credentials** in any field.
- Fields containing user-provided text or structured payloads must be sanitized before persistence.
- Replace known secret-like values with `"[REDACTED]"`.
- If a full object cannot be safely persisted, store a minimized summary and set `redaction_applied: true`.

### Redaction targets (non-exhaustive)

- API keys, bearer tokens, JWTs, OAuth codes, refresh tokens.
- Passwords, passphrases, private keys, seed phrases.
- Raw authorization headers, cookie headers, session IDs.
- Connection strings or DSNs containing credentials.

## Tool call audit event schema

### Purpose

Captures normalized audit records for every tool invocation and decision lifecycle.

### JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/schemas/tool-call-audit-event.json",
  "title": "ToolCallAuditEvent",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "event_type",
    "event_id",
    "timestamp",
    "tool_name",
    "validated_args",
    "decision",
    "confirmation",
    "result"
  ],
  "properties": {
    "event_type": { "const": "tool_call_audit" },
    "event_id": { "type": "string", "minLength": 1 },
    "timestamp": { "type": "string", "format": "date-time" },
    "tool_name": { "type": "string", "minLength": 1 },
    "validated_args": {
      "type": "object",
      "description": "Post-validation arguments with sensitive values redacted.",
      "additionalProperties": true
    },
    "decision": {
      "type": "object",
      "additionalProperties": false,
      "required": ["status", "reason"],
      "properties": {
        "status": { "type": "string", "enum": ["allow", "deny", "defer"] },
        "reason": { "type": "string", "minLength": 1 },
        "policy_ids": {
          "type": "array",
          "items": { "type": "string", "minLength": 1 }
        }
      }
    },
    "confirmation": {
      "type": "object",
      "additionalProperties": false,
      "required": ["required", "obtained"],
      "properties": {
        "required": { "type": "boolean" },
        "obtained": { "type": "boolean" },
        "channel": { "type": "string", "enum": ["none", "ui", "api", "policy"] },
        "actor": { "type": "string" }
      }
    },
    "result": {
      "type": "object",
      "additionalProperties": false,
      "required": ["status"],
      "properties": {
        "status": { "type": "string", "enum": ["success", "failure", "blocked", "skipped"] },
        "duration_ms": { "type": "integer", "minimum": 0 },
        "output_summary": { "type": "string" }
      }
    },
    "error": {
      "type": "object",
      "additionalProperties": false,
      "required": ["code", "message"],
      "properties": {
        "code": { "type": "string", "minLength": 1 },
        "message": { "type": "string", "minLength": 1 },
        "retryable": { "type": "boolean" }
      }
    },
    "redaction_applied": { "type": "boolean", "default": false }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "result": {
            "properties": { "status": { "const": "failure" } },
            "required": ["status"]
          }
        }
      },
      "then": { "required": ["error"] }
    }
  ]
}
```

### Field requirements summary

- **Required:** `event_type`, `event_id`, `timestamp`, `tool_name`, `validated_args`, `decision`, `confirmation`, `result`
- **Optional:** `error` (required on failure), `redaction_applied`

### Logging rules

- `validated_args` must include only normalized values safe for storage.
- `output_summary` must be concise and sanitized (no raw payload dumps).
- `error.message` must avoid echoing secret-bearing input.
