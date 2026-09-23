# AGENTS.md

Instructions for AI coding agents (Claude Code, Codex, Cursor, Copilot, and others) working with Formbear, or with this repository.

## What this repository is

The agent-facing package for [Formbear](https://formbear.app), an EU-hosted form and survey builder:

- `skills/formbear/SKILL.md`: the skill. Install with `npx skills add sigurdarson/formbear-agent-skills`.
- `plugin.json` and `mcp.json`: an [Agent Plugins](https://agent-plugins.org) manifest and the MCP server config.
- This file: how to interact with Formbear as an agent.

The product's source code is not in this repository. Formbear's own site publishes everything an agent needs: `https://formbear.app/llms.txt` (site map), `https://formbear.app/auth.md` (credentials), `https://formbear.app/openapi.json` (REST API), and every docs page as markdown by appending `.md` to its URL.

## Connecting to Formbear

- **MCP**: `https://formbear.app/api/mcp` (Streamable HTTP). The client signs the user in with OAuth 2.1; no manual token needed. A public docs server with no sign-in is at `https://formbear.app/api/mcp/docs`.
- **REST**: `POST https://formbear.app/api/v1/tools/{tool}` with a JSON body, bearer-authenticated with a workspace API token (`fbk_...`, created in the app under Settings, API) or an OAuth access token. Errors are JSON with `code`, `message`, and `hint`.
- Scopes: `forms:read`, `forms:write`, `responses:read`, `responses:write`. Request the least you need.

## Rules of engagement

1. **Check the plan before promising a write.** `get_workspace` returns `plan`. Write tools need Pro; on Free they answer `pro_required`.
2. **Edit by block id.** Every question has a stable id. Never rebuild a form to change one question, and never remove and re-add a question to rename it: that discards its answers.
3. **Drafts are safe; publishing is the change.** Block and design edits sit in the draft until `publish_form`. Settings (open/close, schedule, notifications) apply immediately.
4. **Confirm destructive actions with the user.** `delete_form` needs the exact title as confirmation; `delete_response` is permanent. Ask first.
5. **Prefer aggregates over raw responses.** `summarize_responses` and `get_form_analytics` answer most questions; page through `list_responses` only when the user needs individual answers. `analyze_responses` spends one of the workspace's monthly AI actions; say so.
6. **Respect rate limits.** 120 requests per minute per credential, 240 per IP. A 429 carries `Retry-After`.
7. **Keep respondent data where the user put it.** Answers are personal data under GDPR. Do not copy them into other tools or files unless the user asked for exactly that.

## Working on this repository

- Keep `skills/formbear/SKILL.md` byte-identical to the copy Formbear serves at `https://formbear.app/.well-known/agent-skills/formbear/SKILL.md`; the discovery index publishes a digest of it. Changes originate in the Formbear codebase and are mirrored here.
- Do not add tools, endpoints, or plan claims that the docs at `https://formbear.app/docs` do not state.
- No em dashes in any text (project style).
