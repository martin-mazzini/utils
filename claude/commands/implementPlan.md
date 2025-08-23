# Implement Plan

Implement a feature based on its implementation plan file.

Usage: /implementPlan [plan-filename]

Instructions for Claude:
1. Read the implementation plan file from `./memories/plans/[plan-filename].md`
2. Look for the "Prerequisite read:" section at the top of the plan file and read ALL listed documents from the `./memories` folder
3. Review the implementation steps and file locations specified in the plan
4. For each implementation step in the plan:
   - Read relevant existing code files to understand patterns and conventions
   - Implement the changes exactly as described in the plan
   - Follow existing code patterns, naming conventions, and architecture
   - Ensure type safety and proper error handling
   - Write clean, readable code
   - DO NOT WRITE ANY CODE COMMENTS.
5. After implementing each major component:
   - Verify the code compiles/runs without errors
   - Check that the implementation matches the plan's specifications
   - Ensure no existing functionality is broken
6. Complete ALL implementation steps listed in the plan
7. Run any lint/typecheck commands if they exist (check package.json scripts)
8. Create a summary of completed changes

Critical implementation guidelines:
- Follow the plan exactly - do not deviate or add features not specified
- Maintain consistency with existing codebase patterns
- Handle edge cases and errors appropriately
- If any step is unclear or blocked, ask for clarification before proceeding