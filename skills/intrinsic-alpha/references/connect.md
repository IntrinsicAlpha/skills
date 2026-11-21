# Connect the Intrinsic Alpha MCP server

**Server URL:** `https://intrinsicalpha.com/mcp`

This is a remote server using Streamable HTTP with OAuth 2.1 sign-in. There is no API key to paste. The client opens Intrinsic Alpha in the browser; the user signs in with their normal account (free accounts work) and approves the client on the consent screen.

Create an account at https://intrinsicalpha.com/signup if needed.

## Claude (claude.ai, desktop, mobile)

1. Open **Settings → Connectors**.
2. Choose **Add custom connector** and paste `https://intrinsicalpha.com/mcp`.
3. Select **Connect** and sign in.

Valuation cards and financial charts render inline.

## Claude Code

```bash
claude mcp add --transport http intrinsic-alpha https://intrinsicalpha.com/mcp
```

Then run `/mcp` in Claude Code, select `intrinsic-alpha`, and choose **Authenticate**.

You can also install the plugin, which bundles this skill and the server:

```text
/plugin marketplace add IntrinsicAlpha/skills
/plugin install intrinsic-alpha@intrinsic-alpha
```

## ChatGPT

1. In **Settings → Apps & Connectors**, turn on developer mode.
2. Create a connector with the URL `https://intrinsicalpha.com/mcp` and choose OAuth sign-in.

Valuation cards and financial charts render inline.

## Cursor

Add this to `.cursor/mcp.json` in the project or to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "intrinsic-alpha": {
      "url": "https://intrinsicalpha.com/mcp"
    }
  }
}
```

Sign in when Cursor asks.

## VS Code (GitHub Copilot)

Add this to `.vscode/mcp.json`:

```json
{
  "servers": {
    "intrinsic-alpha": {
      "type": "http",
      "url": "https://intrinsicalpha.com/mcp"
    }
  }
}
```

## Codex CLI

Add this to `~/.codex/config.toml`:

```toml
[mcp_servers.intrinsic-alpha]
url = "https://intrinsicalpha.com/mcp"
```

Then run `codex mcp login intrinsic-alpha`.

## Gemini CLI

Add this to `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "intrinsic-alpha": {
      "httpUrl": "https://intrinsicalpha.com/mcp"
    }
  }
}
```

## Other clients

Any MCP client that supports remote servers over Streamable HTTP with OAuth sign-in can connect. For clients that only support local stdio servers, use a bridge:

```json
{
  "mcpServers": {
    "intrinsic-alpha": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://intrinsicalpha.com/mcp"]
    }
  }
}
```

## Troubleshooting

- **No sign-in window:** the client must support OAuth for remote MCP servers. Update the client or use `mcp-remote`.
- **Tools missing after sign-in:** restart or reload the client's MCP connections.
- **Privacy:** connected apps see the user's name and email and read market data and plan usage. They never see watchlists, the journal, notes, or saved DCF scenarios.
