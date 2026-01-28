# Sitting at a Slot Machine

You know that feeling when someone says something that rings so true that you can feel it begin to change the way you think?

> "Sometimes I feel like I'm sitting at a slot machine, just pulling the handle and winning every time."

## My Introduction

My vibe coding journey began at the end of September 2025. I had been hearing about Cursor and Claude Code for months, but what really set me over the edge was that two of the most technical people I know were using Claude Code as their daily driver for real business.

One day I got home and opened [this video](https://www.youtube.com/watch?v=PCvbhY4xV2c) and began rebuilding my personal website. If all I could get out of this was extricating myself from a Squarespace subscription, I'd count it a win.

Little did I know, everything was about to change.

But this isn't the story of how AI agents changed my life (that story is still being written). This is the story of how quickly you can veer into a dead end when intoxicated with unlimited execution.

## The Seed

As I watched that video, I saw Alex Finn init a `CLAUDE.md` file and copy/paste a set of rules into "every new project":

```
Claude Code Rules:
1. First think through the problem, read the codebase for relevant files, and write a plan to tasks/todo.md.
2. The plan should have a list of todo items that you can check off as you complete them
3. Before you begin working, check in with me and I will verify the plan.
4. Then, begin working on the todo items, marking them as complete as you go.
5. Please every step of the way just give me a high level explanation of what changes you made
6. Make every task and code change you do as simple as possible. We want to avoid making any massive or complex changes. Every change should impact as little code as possible. Everything is about simplicity.
7. Finally, add a review section to the todo.md file with a summary of the changes you made and any other relevant information.
8. DO NOT BE LAZY. NEVER BE LAZY. IF THERE IS A BUG FIND THE ROOT CAUSE AND FIX IT. NO TEMPORARY FIXES. YOU ARE A SENIOR DEVELOPER. NEVER BE LAZY
9. MAKE ALL FIXES AND CODE CHANGES AS SIMPLE AS HUMANLY POSSIBLE...
```

My first thought, even before I really started building anything, was "there HAS to be a better way than copy/pasting this into every project." And as I watched Alex Finn copy/paste intermediate versions of planning docs back and forth between Claude Code and ChatGPT, I began to think "what if I externalized as much planning and context documentation as possible... then ChatGPT would be able to review all of it. Maybe I would be able to bypass the effects of auto-compacting. Maybe I could make the handoff to other agents easy (I was already nervous about being locked in to Claude Code)."

The tipping point came after I wrote out a prompt for code reviews for the nth time... why am I rewriting the same thing over and over?

All of this was solvable.

These were the seeds that eventually grew into the AI Context System. Seeds that grew into 22 commands, 14 agents, and 150KB of shell scripts. Into 1,100 files and 436,000 lines of code across 15 projects.

Seeds that grew into weeds... and weeds that, as of today, I have ripped out of my garden.

## Unbound Growth

On October 4, 2025, I made my first commit. By the end of that day I had made over 30 commits and gone from v1.0 to v1.3.3. The system had an update command, a migration command, template syncing, version detection. I was solving problems at a pace I had never experienced before.

It was intoxicating.

In retrospect, I committed to the unbounded feedback loop from the very beginning. Every time I would install the system, I'd ask the instance of Claude Code to provide feedback of bugs, things that were unclear and opportunities for improvement. Then I would bring that feedback back to the AI Context System and just have it upgrade the system based on that.

Over the next few months, I went through six major versions. Each one fixed problems introduced by the previous one. Each one added features to address edge cases. Each one felt like progress.

Eventually I got tired of collecting the feedback files each of my projects generated, and so I built a feedback API where Claude could POST issues with severity, category, and project info to a local server. Then I built an analyzer dashboard that aggregated feedback from all projects with filtering and statistics. I was optimizing the feedback cycle to work with even less friction; upgrades were even easier and felt more substantial.

In early January I was talking with friends about subagents. They were all using them. I realized I was the only one who hadn't really touched them yet. So I refactored all my code reviews to use an orchestrator pattern with specialist agents. By January 20 I had 14 agents. The orchestrator would dispatch findings to each specialist, then a synthesis agent would merge everything into a final report with deduplication and grading.

It looked so good... it felt so good.

But in the deep, dark depths of my subconscious, an itch started to grow. One that grew stronger and stronger, and soon became unbearable. A single, simple question: "is any of this even doing anything?"

## The Wake-Up Call

In January I was on a podcast, and one of them made a comment that I couldn't stop thinking about:

> "I think that for people whose mindsets are engineer-builder mindsets, and the way our brain chemistry works... these things are incredibly addictive, like super addictive, because it hits that reward center that we used to have to slog away for hours - before you get the green test pass or before you get the feature working. And now, all it takes a prompt and watching it go.
>
> Sometimes I feel like I'm sitting at a slot machine, just pulling the handle and winning every time."

The questions I'd been shoving down had grown so loud that they became impossible to ignore. Is the AI Context System actually helping Claude code better? Am I creating more useful context, or am I clogging up limited context windows with irrelevant documentation?

Was I developing something that, in practice, was making everything worse?

So I did what everyone does in situations like these: I asked Claude what it thought. "Give me a honest assessment, how much value is this system providing." You push it a few times, and it'll tell you "my honest assessment: most of this is just theater. We really could get most of the value with just 1 or 2 of these files."

So I tried rebuilding with a bare-bones version. Eight commands instead of 22. No shell scripts. No agents. But sometimes simplification isn't so simple. I began iterating, specifically spending a ton of time on figuring out how to implement the upgrade path. Just a couple days after tearing everything down, I had already released 6 updates.

That's when it hit me... I was still chasing the same dragon that got me here.

And so, I quit. Cold turkey.

## What I Learned

A few things were worth the detour.

**On the practical side:**

- Claude Code loads the `CLAUDE.md` file in the directory you open it in AND all the `CLAUDE.md` files in parent directories. So if you have global rules (style guidelines, git workflow, etc) you can put them in a top-level folder and they'll apply to everything underneath. OpenAI Codex does the same with `AGENTS.md`.
- Saving commands to `~/.claude/commands/` (or `~/.codex/prompts/`) makes them available in all projects.

Between those two insights, I can get most of the functionality I was trying to build.

- The most important file in your project is `CLAUDE.md`. You're better off keeping it updated and succinct than spending time creating elaborate context documentation.
- It's almost impossible to get Claude to automatically engage with a system like this. It was never updating the AI Context System docs unless I explicitly told it to, which somewhat defeated the purpose.

**On the meta side:**

- Claude Code and all coding agents are incredibly well tuned to hit the addiction centers of a developer's brain. The dopamine release from feeling like you're accomplishing so much is just as powerful as the mechanisms that Meta builds into Facebook or Caesars builds into slot machines.
- If you ask the AI what to build, it will give you answers. Always. But it will rarely tell you that you are not asking the right questions.
- We've all heard about the sycophancy of chat agents ("incredible insight!" etc), but what's less talked about is the more subtle form of that when engaging in long building tasks. The AI may never be openly sycophantic, but it can easily have the same effect as you make incredible progress on a project that's irrelevant.
- When you're working with AI agents you're working with abundance. The value you bring as a developer shifts from creating to pruning, from adding to subtracting.

And most importantly: I still don't really know how to use Claude Code well. I have no way to measure if what I'm doing is helping or slowing down the system.

What I ended up with: three global commands installed to `~/.claude/commands/` and `~/.codex/prompts/`:

1. `/update-context` extracts permanent learnings and updates CLAUDE.md
2. `/save-session` records session history when you want it
3. `/review` runs a comprehensive code review

No framework. No installation per-project. No versions.

## The Aftermath

Once I made the decision I built a cleanup command and removed the AI Context System from every project I'd installed it in. Fifteen projects. Over 1,100 files. 436,000 lines of code, most of it backup directories from migrations between versions I'd already abandoned.

It felt like stumbling into the sunlight out of a Vegas Casino.
