# Publishing

Maintainer notes for releasing the skill and plugins. Bump `version` in `plugin.json` and `.claude-plugin/plugin.json` together.

## ChatGPT and Codex Plugin Directory

1. Build the ZIP from the repository root. It contains `plugin.json`, `mcp.json`, the skill, and the icons `plugin.json` references:

   ```sh
   mkdir -p dist && rm -f dist/intrinsic-alpha-openai-plugin.zip
   zip -qr -X dist/intrinsic-alpha-openai-plugin.zip plugin.json mcp.json skills/intrinsic-alpha \
     assets/app-icon.png assets/mark.png assets/mark-white.png -x '*.DS_Store'
   ```
2. Go to https://platform.openai.com/plugins, choose **Upload new or existing plugin**, pick the verified developer identity, and upload the ZIP.
3. Verify the domain. Serve the dashboard token as plain text at `https://intrinsicalpha.com/.well-known/openai-apps-challenge`.
4. Connect the MCP server `https://intrinsicalpha.com/mcp` with **With MCP**. Only one server can be connected per plugin, and its URL is fixed after submission.
5. Fill in the review details in the dashboard:
   - The test account credentials. These never go in the ZIP.
   - A demo recording URL (`extensions.com.openai.review.demo_recording_url`), which is required for MCP review.
6. Run the automated scans and submit for review. After approval, choose when to publish.

The test cases in `plugin.json` (`extensions.com.openai.review`) are the 5 positive and 3 negative cases required for review. Tool changes on the hosted server do not need a new ZIP. Listing text, icons, and test cases do.

## Claude Code

`.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json` are validated with `claude plugin validate .`. Submit the repository root at https://claude.ai/directory/manage as a **Plugin bundle**, and the server separately as an **MCP connector**.

The Claude plugin directory accepts only Markdown, text, JSON, YAML, and PNG, JPEG, GIF, WebP, or ICO images from unverified organizations. Do not commit scripts, files starting with `#!`, package manager files, `AGENTS.md` or `CLAUDE.md`, or SVGs; keep packaging commands in this file and images as PNG.

## skills.sh

The skill appears on skills.sh automatically once people install it with `npx skills add IntrinsicAlpha/skills`. Check discovery with `npx skills add IntrinsicAlpha/skills --list`.
