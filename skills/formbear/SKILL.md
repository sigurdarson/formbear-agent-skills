---
name: formbear
description: Work with Formbear, the EU-hosted form and survey builder, from an agent. Read a workspace's forms, responses, and analytics on any plan; create, edit, publish, and manage forms on Pro. Use when a user mentions Formbear, a Formbear form or survey, or wants to collect or analyze responses with it.
---

# Formbear

Formbear (https://formbear.app) is a design-led, EU-hosted form and survey builder. A workspace holds forms; a form is an ordered list of blocks (questions and content) with a draft schema and a published snapshot; responses are stored per form, keyed by stable block ids.

## Connect

Two transports, one credential, same tools:

- **MCP** (Streamable HTTP): `https://formbear.app/api/mcp`. Add it as a remote server; the client signs the user in with OAuth (magic link, then a consent page where they pick the workspace).
- **REST**: `POST https://formbear.app/api/v1/tools/{tool}` with a JSON body of arguments. OpenAPI: `https://formbear.app/openapi.json`. Unauthenticated `GET /api/v1` returns a 401 whose `WWW-Authenticate` header points at the protected-resource metadata.

Credentials:

- A **workspace API token** (`fbk_...`), created by an owner or admin under Settings, API. Send as `Authorization: Bearer`.
- An **OAuth 2.1 access token** from Formbear's own authorization server (PKCE, dynamic client registration, Client ID Metadata Documents). Scopes: `forms:read`, `forms:write`, `responses:read`, `responses:write`. Ask for the least you need.

Full walkthrough: https://formbear.app/auth.md. Public docs without a credential: the docs MCP server at `https://formbear.app/api/mcp/docs`, or any doc page with `.md` appended.

## Plan boundaries

Read tools work on every plan. Write tools (create, edit, publish, delete) need a **Pro** workspace; on Free they return a `pro_required` error. Never promise a write on a Free workspace: call `get_workspace` first and read `plan`.

## Tools, in the order you usually need them

1. `get_workspace`: name, plan, your role, members.
2. `list_forms`: every form with status (draft or published), response counts, and its public id.
3. `get_form`: one form in full: blocks with ids, settings, design, and its public URL.
4. `list_responses` / `get_response`: answers keyed by question, paged with `offset`, bounded by date. `summarize_responses`: per-question aggregates (counts, averages). Prefer the summary over paging through raw responses.
5. `get_form_analytics`: views, visitors, completion rate, breakdowns (Free: last 7 days).
6. `analyze_responses`: an AI digest of the responses. Costs one of the workspace's monthly AI actions (5 on Free, 100 on Pro); say so before calling it.
7. `search_docs`: the Formbear docs, for how a feature works.

Pro write tools: `create_form`, `update_form`, `add_blocks`, `update_block`, `move_block`, `remove_blocks`, `publish_form`, `update_form_settings`, `update_form_design`, `duplicate_form`, `delete_form`, `delete_response`, `restore_form_version`, `list_form_versions`.

## Editing forms safely

- Every block has a **stable id**. Edit by id; never rebuild a form from scratch to change one question, and never rename a question by removing and re-adding it (that discards its answers).
- Block and design edits land in the **draft**. Nothing changes for respondents until `publish_form`. Settings (open/close, schedule, notifications) apply immediately.
- A change that would discard existing answers is refused until you confirm with the user. Relay the refusal; do not retry blindly.
- `delete_form` requires the form's exact title as confirmation. Ask the user before deleting anything.

## Good first moves

- "Which of my forms got the most responses this month?" → `list_forms`, then `summarize_responses` on the top one.
- "Add an optional phone number after the email question on my contact form, then publish." → `get_form` (find the email block id) → `add_blocks` at that position → `publish_form`.
- "Close the signup form on Friday and notify Ada." → `get_workspace` (find Ada's member id) → `update_form_settings`.

## Limits and errors

120 requests per minute per credential, 240 per IP; a 429 carries `Retry-After`. REST errors are JSON: `{ "error": { "code", "message", "hint" } }`. Codes: `unauthorized`, `insufficient_scope`, `pro_required`, `forbidden`, `invalid_arguments`, `not_found`, `tool_error`, `rate_limited`.

## Privacy

The agent acts with the user's access and sees only their workspace. Response answers are decrypted on Formbear's server for that request only and never leave EU infrastructure. Do not paste raw respondent data into places the user did not ask for.
