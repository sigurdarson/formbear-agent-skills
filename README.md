# Formbear for agents

Skills, agent instructions, and MCP config for [Formbear](https://formbear.app), the EU-hosted form and survey builder.

## Install the skill

```bash
npx skills add sigurdarson/formbear-agent-skills
```

The skill teaches an agent how to connect to a Formbear workspace, which tools exist, what the Free and Pro plans allow, and how to edit forms without losing responses. It is also served by Formbear itself at `https://formbear.app/.well-known/agent-skills/formbear/SKILL.md`.

## Add the MCP servers

`mcp.json` lists both servers:

- `https://formbear.app/api/mcp`: the workspace server. OAuth sign-in, or a workspace API token.
- `https://formbear.app/api/mcp/docs`: the public documentation server. No credential.

Claude Code:

```bash
claude mcp add formbear --transport http https://formbear.app/api/mcp
claude mcp add formbear-docs --transport http https://formbear.app/api/mcp/docs
```

## REST instead of MCP

Every tool is also `POST https://formbear.app/api/v1/tools/{tool}`, described by the OpenAPI document at `https://formbear.app/openapi.json`. Authentication is explained at `https://formbear.app/auth.md`.

## Files

- `skills/formbear/SKILL.md`: the skill.
- `AGENTS.md`: rules of engagement for coding agents.
- `plugin.json`, `mcp.json`: an [Agent Plugins](https://agent-plugins.org) manifest.

## Support

support@formbear.app. Docs: https://formbear.app/docs/mcp-connector.
