  ---
  description: Review a single commit
  ---

  ## Context
  You need to run git commands to see the commit details:
  git show HEAD

  ## Task
  After running the git commands above, review the commit changes.

  1. **Scope and motivation**
     - Summarise what was implemented and why.
     - If the reason is not obvious, state a clear assumption label `[Assumption]`.

  2. **State change**
     - Describe the previous behaviour or state.
     - Describe the new behaviour or state that the commit achieves.

  3. **Key changes**
     - Walk through the diff in a human-friendly order.
     - For each affected file, explain how business logic, data flow, or APIs were modified.
     - Highlight the simplest mental model to understand the update.

  4. **Minor tweaks and clean-ups**
     - Briefly note small refactors, renames, or style fixes.

  5. **Follow-up Q&A**
     - End with a line:
       `Let me know what part you want to dig into and I will explain further.`

  Rules for this review:
  - Keep the first pass succinct – prioritise clarity over exhaustiveness.
  - Never invent facts. If something cannot be concluded, say **"Not enough information"**.
  - Use bullets and short paragraphs. Avoid wall-of-text responses.