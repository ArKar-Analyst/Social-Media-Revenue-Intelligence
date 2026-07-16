# Social Media Revenue Intelligence

SQL-based analysis of a simulated social media platform's revenue ecosystem, 
identifying high-value user segments and ad performance drivers to improve 
monetization efficiency per user.

## 📊 Project Overview
**Objective:** Increase monetization efficiency per user by identifying 
high-value segments and optimizing ad placements.

**Business Questions:**
1. Which users generate the highest ad revenue?
2. What content drives maximum ad clicks?
3. What is ARPU (Average Revenue Per User)?
4. Which demographic has the highest CTR?

**Dataset:** 50,000 Users · 300 Ads · 200K Impressions · 11,938 Clicks · 8,000 Subscriptions

## 🗂 Data Model
5 relational tables — `users`, `ads`, `ad_impressions`, `ad_clicks`, `subscriptions` — 
linked via `user_id` and `ad_id`. Full ER diagram in the presentation deck.

## 🔑 Key Findings
- **Overall CTR:** 5.97%, stable across months with a Sep'25 peak of 6.17%
- **ARPU:** $2.19 | **Total Revenue:** $109,619 — subscriptions drive 73% of revenue
- **Top segment:** Premium Subscribers (16% of users) generate 77% of revenue
- **Top ad categories:** Fashion (highest CTR at 6.14%), Finance (highest click revenue)
- **Top age groups by CTR:** 18–24 (6.06%) and 45–59 (6.04%)
- **Top markets:** Canada (6.08%) and Germany (6.05%)

## 💡 Strategic Recommendations
1. Drive premium subscription conversions among the 84% free-tier users
2. Increase ad inventory for Finance and Fashion categories
3. Prioritize ad delivery to 18–24 and 45–59 age segments
4. Geo-optimize premium ad slots for Canada and Germany

## 🛠 Tools Used
SQL (MySQL) for querying and analysis · Canva for the presentation deck

## 📁 Files
- `Queries.sql` — All analysis queries (CTR, revenue segmentation, ARPU, demographic breakdowns)
- `data/` — Raw dataset (5 CSV tables)
- `Social_Media_Revenue_Intelligence.pdf` — Full presentation deck with visuals and insights

## 👤 Author
Arkadeep Kar
