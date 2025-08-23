We are reviewing modified files in the working directory — this includes both staged and unstaged changes — compared to the last commit (HEAD). I want you to:

1. **Identify all modified files** (don't care if they're staged or unstaged).
2. For each modified file:
   - **Explain what the file is doing overall**, assuming I’m only vaguely familiar with it.
   - **Explain the changes in context**, not just what changed but **why** it might matter or how it fits into the bigger picture.
   - **Modify the actual files by adding inline comments** that:
     - Explain the overall logic, purpose, and flow of the file.
     - Explain key functions, data structures, or blocks (especially those affected by the change).
     - Explain the specific changes (diffs), but **always within the context of the file as a whole**.
     - Do **not** worry about being verbose or production-quality — prioritize making it **understandable for a human** who is learning or trying to grasp the code.
     - Comments should be natural-language and can be full paragraphs if needed.
     - Feel free to comment on parts of the file that were *not* changed, if it helps make the change clearer.

This is not a code review — it's a **code explanation session**. Assume the goal is to **teach me how the modified files work** and **why the changes make sense**.
Act as if you’re onboarding someone new into this codebase and these were their first changes to understand.