 ---
  description: Review uncommitted local changes
  ---

  ## Context
  You need to run git command to see all uncommitted changes:
  git diff && git diff --cached && git diff --no-index /dev/null $(git ls-files --others --exclude-standard)


  ## Task
  After running the git commands above, review all uncommitted changes (untracked files, unstaged changes, and staged
  changes).

  1. **Scope and motivation**
     - Summarise what is being implemented and why.
     - If the reason is not obvious, state a clear assumption label `[Assumption]`.

  2. **State change**
     - Describe the current state before these changes.
     - Describe the new behaviour or state that the changes will achieve.

  3. **Key changes**
     - Walk through the changes in a human-friendly order.
     - For each affected file, explain how business logic, data flow, or APIs are being modified.
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