# Intrinsic Alpha MCP tool reference

Server: `https://intrinsicalpha.com/mcp` (Streamable HTTP, OAuth 2.1 sign-in, stateless).

Every stock tool accepts:

- `ticker` (required): ticker symbol or company name, such as `AAPL` or `Apple`.
- `exchange` (optional): `NASDAQ`, `NYSE`, and so on, when a ticker is listed on more than one exchange.

Results are compact JSON text. Every stock result includes `stock.ticker`, `stock.exchange`, `stock.companyName`, and an absolute `stock.reportUrl`. Unknown tickers return an error that suggests `search_stocks`.

The server only covers companies listed on U.S. exchanges. That includes foreign issuers and ADRs listed there, whose figures may be in a non-USD reporting currency.

---

## search_stocks (free)

Find covered stocks by ticker prefix or part of a company name.

| Argument | Type | Default |
|---|---|---|
| `query` | string, 1–100 chars | required |
| `limit` | integer 1–25 | 10 |

Returns `results[]` with `ticker`, `exchange`, `companyName`, `sector`, `industry`, `country`, and `reportUrl`.

## get_stock_snapshot (free)

The current profile and the latest annual figures in one call. Start here for a quick overview.

Returns:

- `stock.profile`: `price`, `marketCap`, `peRatioTtm`, `forwardPe`, `epsTtm`, `priceToBook`, `priceToSales`, `evToEbitda`, `roe`, `roa`, `roic`, `dividendYield`, `debtToEquity`, and `beta`.
- `latestAnnual.income`: revenue, gross profit, operating income, net income, EPS, diluted EPS, and EBITDA.
- `latestAnnual.balanceSheet`: cash, total assets, total liabilities, total debt, and stockholders' equity.
- `latestAnnual.cashFlow`: operating cash flow, capex, free cash flow, dividends paid, and buybacks (`commonStockRepurchased`).
- `latestAnnual.ratios`: gross, operating, and net margin, ROE, ROIC, debt to equity, current ratio, and dividend yield.
- `latestAnnual.keyMetrics`: revenue, net income, free cash flow, and book value per share, plus P/E, P/S, and P/FCF.

It does **not** include Intrinsic Alpha's intrinsic value; use `get_intrinsic_value` for that. Margin and return fields are usually fractions (`0.47` = 47%). Check the magnitude before you format them.

## get_financial_statements (free)

Reported rows, newest first.

| Argument | Type | Default |
|---|---|---|
| `statement` | `income` \| `balance_sheet` \| `cash_flow` \| `ratios` \| `key_metrics` | required |
| `period` | `annual` \| `quarterly` | `annual` |
| `limit` | integer 1–12 | 5 |
| `fiscalYear` | integer | all recent periods |

Returns `rows[]` with the full statement line items, plus `fiscalYear`, `fiscalQuarter`, `date`, `fillingDate`, and `reportedCurrency`.

## get_financial_history (free, renders a chart)

One to six metrics over recent periods, oldest to newest. Use it for trends and growth questions.

| Argument | Type | Default |
|---|---|---|
| `metrics` | array of 1–6 metric keys | `["revenue", "net_income", "free_cash_flow"]` |
| `period` | `annual` \| `quarterly` | `annual` |
| `periods` | integer 2–12 (annual max 10, quarterly max 12) | 6 |

Metric keys:

- Income: `revenue`, `gross_profit`, `operating_income`, `net_income`, `eps`, `eps_diluted`, `ebitda`
- Balance sheet: `cash`, `total_assets`, `total_liabilities`, `total_debt`, `stockholders_equity`
- Cash flow: `operating_cash_flow`, `free_cash_flow`, `capital_expenditures`, `dividends_paid`, `buybacks`
- Valuation: `pe_ratio`, `price_to_sales`, `price_to_free_cash_flow`
- Margins and returns: `gross_margin`, `operating_margin`, `net_margin`, `roe`, `roic`
- Health and income: `debt_to_equity`, `current_ratio`, `dividend_yield`

Each `series[]` item has:

- `metric`: `key`, `label`, and `unit` (`currency`, `per_share`, `ratio`, or `percent`).
- `points[]`: `label` (such as `FY 2026` or `Q3 2026`), `date`, raw `value`, a formatted `displayValue`, and `yearOverYearChange`.
- `overall` (annual series only): `from`, `to`, `totalChange`, and `compoundAnnualGrowth`.

Percent metrics are stored as fractions in `value`, and their changes are given in percentage points. Quote `displayValue`, `yearOverYearChange`, and `overall` instead of recalculating.

## get_estimates (free)

| Argument | Type | Default |
|---|---|---|
| `period` | `annual` \| `quarterly` | `annual` |

Returns two lists:

- `estimates[]` starts at the previous calendar year. Each row has `date`, `currency`, `revenueAvg`, `revenueLow`, `revenueHigh`, `epsAvg`, `epsLow`, `epsHigh`, `numAnalystsRevenue`, and `numAnalystsEps`.
- `priceTargets` holds published analyst price targets.

## get_analyst_ratings (free)

Returns:

- `current`: today's buy, hold, and sell breakdown.
- `last90Days`: a tally of rating actions in the last 90 days.
- `history`: up to 12 months of rating snapshots.
- `recentActions`: recent upgrades and downgrades.

## get_peers (free)

Returns `peers[]`, up to 10 competitors with key comparison figures.

## get_revenue_segments (free)

| Argument | Type | Default |
|---|---|---|
| `segmentType` | `product` \| `geographic` | `product` |
| `period` | `annual` \| `quarterly` | `annual` |

Returns `currency`, `available`, and up to six `periods[]` with segment revenue, segment shares, and revenue not attributed to a segment.

## get_financial_scores (free)

Returns `scores`: the Piotroski F-Score (0–9; higher is stronger) and the Altman Z-Score (distress risk; higher is safer), each with its inputs.

## get_intrinsic_value (metered, renders a valuation card)

Intrinsic Alpha's system DCF valuation.

**Cost:** one weekly intrinsic value unlock per new ticker. Tickers already unlocked this week and the demo ticker `AAPL` are free. No unlock is used when the stock has no valuation.

Returns:

- `newlyUnlocked`: whether this call used an unlock.
- `remainingUnlocksThisWeek`: a number, `"unlimited"`, or `null` for demo tickers.
- `valuation`:
  - `currency`, `currentPrice`, `consensusValue` (intrinsic value per share), and `marginOfSafety`
  - `avgDiscountRate`, `avgGrowthRate`, `sharesOutstanding`, `primaryModel`, and `generatedAt`
  - `models[]`: `type`, `intrinsicValue`, `discountRate`, `growthRate`, `terminalGrowthRate`, `yearlyGrowthRates`, `baseCf`, and `netDebt`

`valuation` is `null` with a `reason` when no system valuation exists. When the weekly limit is reached, the result has `isError: true` and `error: "weekly_intrinsic_value_limit_reached"`, together with `plan`, `resetsAt`, and `upgradeUrl`.

The DCF report is at `${stock.reportUrl}/dcf`.

## ask_intrinsic_alpha (metered)

Runs the same research agent as Ask AI on the website. It reads Intrinsic Alpha's data and may search the web.

| Argument | Type | Default |
|---|---|---|
| `question` | string | required |
| `language` | `en` \| `es` \| `de` | `en` |

**Cost:** one weekly AI assistant prompt per answered question. Empty, failed, or timed-out answers are not charged.

- The agent cannot see your conversation. Make `question` self-contained, with the company and every piece of context it needs.
- Answers take up to about 50 seconds and end with source links and the remaining prompt count.
- The agent uses the system DCF only for tickers the account unlocked this week, and asking never spends an unlock.
- At most two questions run at once per user.

## get_usage (free)

Returns:

- `plan`: `free`, `premium`, or `unlimited`.
- `intrinsicValueUnlocks`: `limit`, `remaining`, and `resetsAt`.
- `aiAssistantPrompts`: `limit`, `remaining`, and `resetsAt`.
- `upgradeUrl`: the pricing page.

## Limits

| Plan | Intrinsic value unlocks / week | AI prompts / week |
|---|---|---|
| Free | 5 | 3 |
| Premium | 15 | 20 |
| Unlimited | unlimited | unlimited |

Weekly allowances reset Monday 00:00 UTC. Plans can change, so `get_usage` is the source of truth. The server allows 120 requests per user per minute and answers `429` with `retry-after` beyond that.
