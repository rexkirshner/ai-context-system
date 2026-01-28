# The AI Context System: A Swan Song

I spent three months building a system to help AI coding assistants maintain context across sessions. It grew to 22 commands, 14 agents, and 150KB of shell scripts. Then I deleted all of it from 15 projects—over 1,100 files and 436,000 lines of code—and felt nothing but relief.

This is the story of what I built, why I killed it, and what I actually learned.

---

## The Itch

It started in mid-October 2025 with a simple annoyance: I kept copy/pasting the same instructions into `CLAUDE.md` files across projects. Claude Code reads this file automatically at session start—that much I knew worked. So I thought: what if I could share commands across projects? What if Claude could remember what we were working on between sessions?

The first version was modest. A few shared commands in `.claude/commands/`. Some helpful utilities. Nothing crazy.

Then the ambition crept in.

"What if we could maintain continuity between sessions?"

"What if there were files that persist what the AI knows—externalized context?"

I didn't know what Claude Code actually needed to be effective. So I adopted a philosophy that felt reasonable at the time:

> "I don't know what it needs, so I'll make everything available and let Claude pick what's useful."

This was the first mistake.

---

## The Expansion

Over the next few months, the AI Context System grew into something I called "comprehensive." Others might call it "monstrous."

**Version 5 had:**
- 22 commands
- 14 specialized agents (security reviewer, performance reviewer, accessibility reviewer, SEO reviewer...)
- 150KB+ of shell scripts
- JSON schemas for validation
- Git hooks
- Multiple context files: `SESSIONS.md`, `CONTEXT.md`, `STATUS.md`, `DECISIONS.md`
- Templates, configs, installation scripts, migration scripts
- 80 unit tests across 11 modules

I built features like "two-layer deduplication (location-based + pattern grouping)" for code reviews. "Weighted grade calculation with severity caps (A-F scale)." Auto-archival when session files exceeded 2,000 lines. A `find_project_root()` function that searched up to 5 levels deep while respecting git boundaries.

Every time Claude suggested an improvement, I built it. Every edge case got handled. Every feature got documented.

The assumption was: more structure = more effective AI. Comprehensive documentation = better context. I was solving problems I had never verified existed.

---

## The Simplification Attempt

By late December, I'd started to notice something uncomfortable: I wasn't using most of what I'd built. The 22 commands? I used maybe 3. The 14 agents? I couldn't tell if they helped. The elaborate session tracking? I never looked at those files.

So I did what felt like a dramatic intervention: Version 6.

**v6 removed:**
- All 14 agents → replaced with simple review prompts
- 150KB of shell scripts → zero scripts
- 22 commands → 8 commands
- JSON schemas → nothing
- Session indexing, auto-archival, thresholds → just use git
- 80 unit tests → no tests needed (it's just prompts now)

I called it "radical simplification." I wrote anti-bloat rules: "If a feature can't be used in 30 seconds, it doesn't ship." I felt good about it.

But v6 still had:
- 8 commands (3 core + 5 reviews)
- 3 context files
- A "Session Loop" ceremony (start by reading STATUS.md, end by running /save-session)
- Installation per project
- Version tracking and migration paths

I had simplified the system without questioning whether the system should exist.

---

## The Wake-Up Call

In January, I recorded an episode of [Signaling Theory](https://sigtheory.com) about AI tools with a few friends. One of them made an offhand comment that I couldn't stop thinking about:

> "Claude Code really hits your addiction centers strongly. You really feel like you're doing so much, but that doesn't really mean you're doing anything."

That landed hard.

I started asking questions I'd been avoiding:
- Is any of this actually helping Claude?
- Have I ever verified that Claude reads STATUS.md unprompted?
- Is "externalized context" even solving a real problem?
- When I start a new session, Claude reads CLAUDE.md, has access to the codebase, can read git history, and I tell it what I'm working on. Is that... enough?

The uncomfortable answer: I had no idea. I'd never tested any of my assumptions. I'd built a system to solve a problem I didn't understand, hoping the system would reveal the answer.

It didn't. It just added layers.

---

## What I Actually Learned

Here's the thing: I don't feel like I wasted three months. I learned things that were worth the detour.

**What auto-loads is your leverage point.** Claude Code reads `CLAUDE.md` automatically. OpenAI Codex reads `AGENTS.md` automatically. This is the one verified mechanism. Everything else is speculation. Build on what you know works.

**Commands are genuinely useful.** Putting reusable prompts in `.claude/commands/` (or `~/.claude/commands/` for global ones) is a real productivity win. This was worth discovering.

**Nested CLAUDE.md files work.** You can have project-level and subdirectory-level context files. Claude respects them. This is good to know.

**AI feedback loops push toward more building.** Every time I asked Claude to review the system, it suggested improvements. Every suggestion felt reasonable. Every improvement added complexity. The AI will always validate building more—it's not going to tell you to stop. You have to decide that yourself.

**Git already does decision tracking.** If you commit frequently with good messages, git history is your decision log. You don't need a separate `DECISIONS.md` file. I ask Claude to commit liberally—the history becomes inherent documentation of how the project evolved.

**Session continuity might not be a problem.** When you start a new session, you have: CLAUDE.md (auto-loads), the codebase (Claude can explore it), git history (Claude can read it), and your own memory of what you're working on. The elaborate "Session Loop" ceremony was solving a problem that might not exist.

---

## What We Ended Up With

Three global commands, installed to `~/.claude/commands/` and `~/.codex/prompts/`:

1. **`/update-context`** — Extracts permanent learnings from the conversation and updates CLAUDE.md and AGENTS.md
2. **`/save-session`** — Records session history when you want it (not automatically)
3. **`/review`** — Comprehensive code review

That's it. No framework. No installation per-project. No versions. No migration paths.

The core philosophy now: one context file per tool (CLAUDE.md for Claude Code, AGENTS.md for Codex), and a command that makes it better over time. The context file captures permanent learnings—how to run tests, constraints, quirks, preferences. Everything else is either in the codebase or in your head.

---

## The Cleanup

Once I made the decision, I felt an overwhelming urge to clean up the mess I'd made. The AI Context System had been installed in 15 projects. It had to go.

I built `/cleanup-acs` and used Claude as a QA engineer to test it. Each cleanup surfaced bugs—missing targets, edge cases, files I'd forgotten about. The command got better as I went.

**The final count** (project names redacted)**:**

| Project | Files Removed | Lines Removed |
|---------|---------------|---------------|
| Project A | 30 | 12,523 |
| Project B | 377 | 120,162 |
| Project C | 46 | 17,432 |
| Project D | 72 | 27,052 |
| Project E | 68 | 25,234 |
| Project F | 73 | 34,128 |
| Project G | 3 | 283 |
| Project H | 118 | 50,999 |
| Project I | 47 | 15,929 |
| Project J | 70 | 32,461 |
| Project K | 33 | 15,926 |
| Project L | 104 | 43,475 |
| Project M | 11 | 913 |
| Project N | 21 | 10,731 |
| Project O | 47 | 28,713 |
| **TOTAL** | **1,120** | **435,961** |

Nearly half a million lines of code, deleted in an afternoon. The largest single project had 377 files and 120,000 lines of ACS artifacts—most of it backup directories from migrations between versions I'd already abandoned.

It felt like taking off a heavy backpack I'd forgotten I was wearing.

---

## Lessons for Others

If you're building tools to help AI assistants work better, here's what I'd tell you:

1. **Start with the problem, not the solution.** I built tools hoping they'd reveal what problem I was solving. They didn't.

2. **Test your assumptions.** I never verified that Claude read STATUS.md unprompted, or that externalized context helped at all. Don't build on speculation.

3. **Complexity is not free.** Every file, command, and pattern has maintenance cost and cognitive load. The weight accumulates.

4. **AI feedback will always suggest more building.** Claude will never tell you to stop. That signal has to come from you.

5. **Simple beats comprehensive.** Three commands beat 22. One file beats five.

6. **Build on verified mechanisms.** CLAUDE.md auto-loads. That's proven. Build there.

7. **Sometimes the answer is "do less."** The best version of the AI Context System is almost nothing.

---

## The Punchline

I spent three months building a complex system to manage AI context.

The answer was: just use the context file that already auto-loads.

The journey wasn't wasted—I learned how to use commands effectively, how nested context files work, and most importantly, how easy it is to get tricked into building more when the AI is your only feedback loop.

Now I have three commands, one context file, and the calm that comes from knowing I'm not carrying around 436,000 lines of machinery I don't need.

---

*The podcast episode that sparked this reckoning: [Signaling Theory Episode 14](https://sigtheory.com/episodes/sigtheory14/) (available January 29, 2026)*

*The cleanup command that removed it all is archived in git history — the job is done.*
