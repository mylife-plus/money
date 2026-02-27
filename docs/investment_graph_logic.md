# Investment Portfolio — Graph & List Logic

## Overview

The portfolio screen shows two things:
1. **A graph** showing how your total portfolio value changed over time
2. **A list** of your investments with their current holdings and value

Both use the same core idea: **your total holdings × the latest known price = portfolio value**.

---

## Time Filters

You can pick a time range using tabs at the bottom of the graph:

| Tab | What it shows |
|-----|--------------|
| **1d** | Today only (from midnight to now) |
| **7d** | Last 7 days |
| **2w** | Last 2 weeks |
| **1m** | Last 1 month |
| **3m** | Last 3 months |
| **6m** | Last 6 months |
| **1y** | Last 1 year |
| **2y** | Last 2 years |
| **5y** | Last 5 years |
| **All** | From your very first investment to now |

**Important:**
- Start time is always **00:00:00** of the start date
- End time is **right now** if the end date is today, or **23:59:59** if it's a past date
- Only tabs that fit your data range are shown (e.g., "5y" won't appear if your data is only 2 years old)

---

## How the Graph Works

### Step 1 — Collect Price Data

The system collects all known prices from two sources within the selected time range:
- **Manual price updates** (prices you entered yourself)
- **Activity prices** (prices recorded when you made a deposit, withdrawal, or trade)

### Step 2 — Divide Time into Points

The time range is split into equal-sized windows. The number of windows depends on the duration:

| Duration | Number of Points | X-Axis Label |
|----------|-----------------|--------------|
| **1 day or 2 days** | 24 points per day (hourly) | Time (e.g., 09:00, 14:00) |
| **3 days to 89 days** | 1 point per day | Date (e.g., 15.03.2025) |
| **90 days or more** | Fixed 90 points (each covers multiple days) | Month-Year (e.g., Jan 2025) or Year (e.g., 2024) for ranges > 2 years |

### Step 3 — Calculate Holdings at Each Point

For each point on the graph, the system replays **all your transactions and trades from the very beginning** (not just the filtered range) up to that point's date. This gives the exact number of units you held at that moment.

For example:
- You bought 10 Apple shares in 2023
- You sold 3 Apple shares in 2024
- At any point after 2024, your Apple holdings = **7 shares**

### Step 4 — Determine Price at Each Point

For each point, the system needs a price for every investment you hold. It works like this:

1. **Before the graph starts**, it loads the last known price for each investment (from all history)
2. **As it moves through each point**, if a new price exists in that window, it updates to the new price
3. **If no new price exists**, it keeps using the previous known price (carry-forward)

This means an investment's price stays the same on the graph until a new price entry (manual or activity-based) appears.

### Step 5 — Calculate Y-Axis Value

For each point:

**Y value = Sum of (holdings × price) for every investment where holdings > 0**

Example at a specific point:
- Apple: 7 shares × $150 = $1,050
- Gold: 5 units × $2,000 = $10,000
- **Total (Y value) = $11,050**

### Step 6 — Graph Stops at Last Data

The graph only shows points up to where actual price data exists. It does not extend with empty/flat data beyond your last price entry.

---

## Percentage Change & Total Value (Top of Graph)

- **Total Value** = the Y value of the **last point** on the graph
- **% Change** = ((last point value − first point value) / first point value) × 100

---

## Investment List (Below the Graph)

The list shows **every investment you currently hold** (regardless of the time filter) with:

- **Holdings**: Your total cumulative units from all time (deposits − withdrawals, buys − sells)
- **Price**: The most recent known price from either a manual update or an activity — whichever is newer (searched across all time, not just the filter range)
- **Total Value**: Holdings × Latest Price

**An investment appears in the list if:**
- Cumulative holdings > 0 (you still own units)

**An investment is hidden if:**
- Its cumulative holdings = 0 (fully sold/withdrawn — considered "closed")

---

## Key Concepts

### Cumulative Holdings
Holdings are always calculated from the **very beginning**, not just the filtered period. If you bought 10 units 3 years ago and are viewing "1 month", you still see all 10 units.

### Price Carry-Forward
If an investment has no new price on a particular day, the system uses its **last known price**. This ensures investments don't disappear from the total just because they weren't updated that day.

### Price Sources
Prices come from two places:
1. **Activity prices** — automatically recorded when you deposit, withdraw, or trade
2. **Manual prices** — prices you add yourself through the price history screen

