---
name: intrinsic-alpha
description: Stock valuation and fundamental research with the Intrinsic Alpha MCP server. Use when the user asks whether a U.S.-listed stock is undervalued or overvalued, wants its intrinsic value, DCF, or margin of safety, asks about financial statements, revenue or free cash flow trends, analyst estimates, price targets, ratings, peers, revenue segments, Piotroski F-Score or Altman Z-Score, or wants to compare companies. Covers tool selection, plan-allowance budgeting, interpreting DCF output, and citing figures with report links. Also helps connect the server when its tools are missing.
license: MIT
metadata:
  author: Intrinsic Alpha
  homepage: https://intrinsicalpha.com/mcp-server
  mcp-server: https://intrinsicalpha.com/mcp
  version: "1.0.0"
---

# Intrinsic Alpha stock research

Intrinsic Alpha's remote MCP server gives you fundamentals, discounted cash flow (DCF) valuations, analyst data, and a research agent for companies listed on U.S. exchanges. Every call runs as the signed-in user and shares that account's plan limits with the website.

## Before you start

Check that the Intrinsic Alpha tools are available. They are named `search_stocks`, `get_stock_snapshot`, `get_intrinsic_value`, and so on, sometimes with a client prefix such as `mcp__intrinsic-alpha__`.

If they are missing, do not invent figures. Tell the user the server is not connected and walk them through [references/connect.md](references/connect.md). The server URL is `https://intrinsicalpha.com/mcp`, and any account, including a free one, can connect.

## Tools and what they cost

| Tool | Use it for | Cost |
|---|---|---|
| `search_stocks` | Resolve a company name or ticker prefix to a ticker and exchange | Free |
| `get_stock_snapshot` | Profile, valuation multiples, latest annual statements, ratios, key metrics, and the growth the price implies (reverse DCF) | Free |
| `get_financial_statements` | Annual or quarterly income statement, balance sheet, cash flow, ratios, or key metrics | Free |
| `get_financial_history` | One to six metrics over 2–12 periods, with YoY change and CAGR; renders a chart | Free |
| `get_estimates` | Consensus revenue and EPS estimates and price targets | Free |
| `get_analyst_ratings` | Buy, hold, and sell breakdown, rating history, upgrades and downgrades | Free |
| `get_peers` | Competitors with their comparison figures | Free |
| `get_revenue_segments` | Revenue by product line or geography | Free |
| `get_financial_scores` | Piotroski F-Score and Altman Z-Score with their inputs | Free |
| `get_usage` | Plan and remaining weekly allowances | Free |
| `get_intrinsic_value` | System DCF: intrinsic value, price, margin of safety, each model; renders a card | **1 weekly unlock per new ticker** |
| `ask_intrinsic_alpha` | Written analysis from Intrinsic Alpha's research agent, with sources | **1 weekly AI prompt per answer** |

Full arguments, enums, and response fields: [references/tools.md](references/tools.md).

## Spend allowances carefully

Unlocks and AI prompts are the user's own weekly allowance, shared with the website. They reset every Monday at 00:00 UTC.

- **Answer from free tools first.** Multiples, statements, trends, estimates, peers, and scores never cost anything.
- **Call `get_intrinsic_value` only when the user wants a valuation** (intrinsic value, fair value, DCF, margin of safety, "is it cheap/expensive?"). Do not call it speculatively for every stock mentioned.
- **Re-checking a ticker is free.** A ticker already unlocked this week does not use another unlock. AAPL is a free demo ticker and never uses one.
- **Ask before spending several.** If a request would value more than two new tickers (for example, "value these five stocks"), call `get_usage` first, tell the user how many unlocks it needs and how many remain, and let them choose.
- **`ask_intrinsic_alpha` is for synthesis, not lookups.** Use it when the user explicitly wants Intrinsic Alpha's analysis or a narrative that needs recent news. Never use it for a single figure that a data tool returns.
- When a limit is reached, the tool returns an error with the plan, reset time, and pricing link. Relay those facts plainly; do not retry, and do not try to work around the limit.

## Workflows

**"Is X undervalued?" / "What's X worth?"**
1. If the ticker is ambiguous, call `search_stocks`.
2. Call `get_intrinsic_value`.
3. Report intrinsic value, current price, margin of safety, the verdict band, the primary model's assumptions, and the DCF report link.
4. Offer a free follow-up, such as charting revenue and free cash flow with `get_financial_history`.

**Trends and growth ("chart revenue for five years", "is margin expanding?")**
Use `get_financial_history` with the specific metrics. Quote its `displayValue`, `yearOverYearChange`, and `overall` CAGR as given.

**Full research brief**
Run the free tools in parallel: `get_stock_snapshot`, `get_financial_history`, `get_estimates`, `get_analyst_ratings`, `get_peers`, `get_financial_scores`. Add `get_intrinsic_value` only if the user wants a valuation verdict. See [references/playbooks.md](references/playbooks.md) for the brief template and the comparison and screening playbooks.

**Compare companies**
Prefer `get_peers` and `get_stock_snapshot` for each name. Value each one only after confirming the unlock cost with the user.

## Reading a valuation

- `consensusValue` is Intrinsic Alpha's per-share intrinsic value. `primaryModel` names the model it is based on, usually `ia_fair_value`.
- `marginOfSafety` is a fraction: (intrinsic value − price) ÷ intrinsic value. `-0.86` means the price is 86% above intrinsic value, measured against intrinsic value. Positive means the stock trades below its intrinsic value.
- Verdict bands match the website: ≥ 25% significantly undervalued, 10% to 25% undervalued, −10% to 10% fairly valued, −25% to −10% overvalued, below −25% significantly overvalued.
- `models` holds every DCF variant: `ia_fair_value` (Intrinsic Alpha fair value), `fcff` (free cash flow to the firm), `fcff_no_capex` (FCFF before capex), `fcfe` (free cash flow to equity), and `net_income`. Each has its own `discountRate`, `growthRate`, `terminalGrowthRate`, and `yearlyGrowthRates`. A wide spread between models shows the value depends heavily on the method; say so.
- `reverseDcf.impliedGrowth` is the yearly growth in `cashFlowMetric` that makes the model's value equal the price: what the price already assumes, not a forecast. In `get_intrinsic_value`, compare it with `reverseDcf.modelGrowth`; a higher implied rate means the price expects more growth than the model. `get_stock_snapshot` gives the implied rate for free, so use it to answer "what is priced in?" without spending an unlock.
- Rates are fractions: `0.103` is 10.3%.
- The valuation depends on its assumptions. Name the discount rate and growth rates, and point the user to the report, where they can change them.

## Answering well

- **Quote, don't recompute.** Tools return `displayValue`, `yearOverYearChange`, CAGR, and margin of safety already computed. Use them verbatim instead of doing your own arithmetic.
- **Label periods and currency.** Say "FY 2026" or "Q2 2026" and the reported currency. Figures are in the company's reporting currency, which may not be USD for foreign issuers.
- **Link the source.** Every result carries an absolute `reportUrl`. Include it so the user can verify. Append `/dcf` for the valuation report.
- **Be explicit about gaps.** If a field is null or a stock has no system valuation, say that the data is unavailable. Do not fill it from memory.
- **Not investment advice.** Present the output as research data and educational analysis. Do not tell the user to buy or sell.
- In clients that support MCP Apps (Claude, ChatGPT), `get_intrinsic_value` and `get_financial_history` render an interactive card or chart. Don't restate every number shown there; summarize the takeaway and add context.

## Errors

- **Stock not found:** call `search_stocks` with the company name, then retry with the returned ticker and `exchange`.
- **No system valuation:** no unlock was used. Fall back to multiples from `get_stock_snapshot` and say that a DCF is not available.
- **Weekly limit reached:** report the plan, reset time, and `upgradeUrl`. Tickers unlocked earlier this week still work.
- **HTTP 429:** the server allows 120 requests per user per minute. Wait for `retry-after` and batch fewer parallel calls.
- **`ask_intrinsic_alpha` timed out or failed:** the prompt was not charged. Answer from the data tools instead.
