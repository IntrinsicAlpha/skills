# Research playbooks

Each playbook says which tools to call and how to shape the answer. Run independent free calls in parallel. Keep answers in the user's language; `ask_intrinsic_alpha` also answers in `en`, `es`, or `de`.

## Quick valuation check

**Trigger:** "Is NVDA overvalued?", "What's Microsoft's fair value?"

1. `get_intrinsic_value` (one unlock if this ticker is new this week).
2. Answer in three or four sentences:
   - The intrinsic value against the current price, with the margin of safety and its verdict band.
   - The primary model and its key assumptions: discount rate, initial growth, and terminal growth.
   - How far apart the models are. If the highest model value is more than double the lowest, say the result depends heavily on the method.
   - The DCF report link, where the user can change the assumptions.
3. Offer a free follow-up, such as a revenue and free cash flow trend or a peer comparison.

## Full research brief

**Trigger:** "Give me a full analysis of COST", "Research Adobe for me".

Call in parallel (all free):

- `get_stock_snapshot`
- `get_financial_history` with `metrics: ["revenue", "operating_income", "free_cash_flow", "operating_margin", "roic"]` and `periods: 6`
- `get_estimates`
- `get_analyst_ratings`
- `get_financial_scores`
- `get_peers`

Add `get_intrinsic_value` if the user wants a valuation verdict, or ask first when unlocks are scarce.

Brief template:

```markdown
## <Company> (<EXCHANGE>:<TICKER>)

**Snapshot:** price, market cap, P/E (TTM and forward), EV/EBITDA, dividend yield.

**Business quality:** revenue and FCF CAGR over the period, margin trend, ROIC, revenue mix (if segments were fetched).

**Financial health:** Piotroski F-Score, Altman Z-Score, debt to equity, current ratio.

**Expectations:** consensus revenue and EPS for the next fiscal year, price target range, analyst rating mix and recent changes.

**Valuation:** intrinsic value vs. price, margin of safety, primary model assumptions. *(Only if fetched.)*

**Peers:** two or three closest competitors on the same metrics.

**What to watch:** two or three points the data raises, such as a decelerating growth rate, a margin squeeze, or rising leverage.

Sources: <reportUrl>, <reportUrl>/dcf
```

Keep it factual, separate data from interpretation, and end without a buy or sell recommendation.

## Compare two or more companies

**Trigger:** "KO vs PEP", "Compare the big three cloud providers".

1. Resolve the names with `search_stocks` if needed.
2. For each company, call `get_stock_snapshot` and `get_financial_history` with the same metrics and periods so the figures line up.
3. Present one table with a column per company, followed by a short narrative.
4. Valuations: count the tickers that are not yet unlocked. If there are more than two, call `get_usage`, state the cost, and ask before calling `get_intrinsic_value` for each one.

## Trend and growth questions

**Trigger:** "Chart Apple's free cash flow", "Has Tesla's margin improved?"

- One call to `get_financial_history` with only the metrics asked for.
- Use `period: "quarterly"` for "recent quarters" or "last year". Quarterly series have no `overall` CAGR, so compare like quarters with `yearOverYearChange`.
- In MCP Apps clients, a chart appears. Summarize the direction and the CAGR instead of listing every point.

## Earnings expectations

**Trigger:** "What do analysts expect for Amazon next year?"

- `get_estimates`, plus `get_analyst_ratings` for sentiment.
- Report the consensus with its low and high range and the analyst count. Separate revenue from EPS.

## Business mix

**Trigger:** "How much of Apple's revenue is services?", "Where does Nvidia sell?"

- `get_revenue_segments` with `segmentType: "product"` or `"geographic"`.
- Give shares of the total and how they shifted over the returned periods. Mention unattributed revenue if it is material.

## Financial health screen

**Trigger:** "Is this company at risk of distress?", "Check the balance sheet".

- `get_financial_scores` and `get_financial_history` with `total_debt`, `cash`, `debt_to_equity`, and `current_ratio`.
- Altman Z-Score zones: below 1.8 is the distress zone, 1.8–3.0 is the grey zone, and above 3.0 is the safe zone. Note that the Z-Score fits financials and very asset-light companies poorly.
- Piotroski F-Score: 8–9 is strong, 0–2 is weak.

## Deep narrative or recent events

**Trigger:** "Why did the stock drop this week?", "Ask Intrinsic Alpha what drives NVIDIA's DCF value".

- `ask_intrinsic_alpha` with a self-contained question, such as "For NVIDIA (NASDAQ:NVDA), what drives the system DCF value and what are the main risks to those assumptions?"
- It costs one AI prompt. If the user did not ask for Intrinsic Alpha's analysis and data tools can answer, use those instead.
- Pass its source links through.
