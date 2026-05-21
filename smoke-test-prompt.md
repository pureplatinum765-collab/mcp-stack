# Perplexity MCP Stack Smoke Test Prompt

Paste the following prompt into Perplexity Enterprise Pro (with MCP connectors enabled) to exercise all 11 connectors in a single read-only pass.

---

## Smoke Test Prompt

```
Using all available MCP connectors, please run the following read-only checks and report results for each:

1. **GitHub** — List the 3 most recently updated repositories on my account (pureplatinum765-collab) and show the latest commit message for each.

2. **Notion** — Search my Notion workspace for any page containing the word "project" and return the title and last edited date of the top 3 results.

3. **Google Drive** — List the 5 most recently modified files in my Drive and show their names and modified dates.

4. **OneDrive** — List the 5 most recently modified files in my OneDrive and show their names and modified dates.

5. **Supabase** — List all tables in my connected Supabase project.

6. **Sentry** — List all projects in my Sentry organization and the count of unresolved issues per project.

7. **Cloudflare** — List all zones (domains) on my Cloudflare account.

8. **Discord** — List the Discord servers the bot is connected to and their channel counts.

9. **Firecrawl** — Scrape https://github.com/pureplatinum765-collab/mcp-stack and return the page title and first paragraph.

10. **Make** — List all active automation scenarios in my Make account.

11. **StackOne** — List all connected accounts in my StackOne workspace.

For each connector, indicate: PASS (data returned), FAIL (error), or SKIP (token not configured).
```

---

## Expected Output Format

| Connector | Status | Notes |
|---|---|---|
| GitHub | PASS / FAIL / SKIP | |
| Notion | PASS / FAIL / SKIP | |
| Google Drive | PASS / FAIL / SKIP | |
| OneDrive | PASS / FAIL / SKIP | |
| Supabase | PASS / FAIL / SKIP | |
| Sentry | PASS / FAIL / SKIP | |
| Cloudflare | PASS / FAIL / SKIP | |
| Discord | PASS / FAIL / SKIP | |
| Firecrawl | PASS / FAIL / SKIP | |
| Make | PASS / FAIL / SKIP | |
| StackOne | PASS / FAIL / SKIP | |
