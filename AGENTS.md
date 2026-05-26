# Voice Pro Codex Instructions

Build the Mac app first.

Hard constraints:
- No video features.
- Optimize for time-to-first-audio.
- Keep components swappable.
- Do not execute arbitrary shell commands from LLM output.
- All CLI execution must go through an allowlisted policy bridge.
- Destructive commands require confirmation.
- Do not store API keys in repo.
- Cloud CI must use mocks for mic, ASR, TTS, and Cerebras.
- Real Mac hardware validation belongs in docs/mac-hardware-validation.md.
