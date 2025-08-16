# memoryExpand

Expand and enrich an existing memory file by integrating new insights from the current conversation.

## Usage

```
/memoryExpand $MEMORY_FILE [optional_instructions]
```

## Arguments

- `$MEMORY_FILE`: Path to the memory file you want to expand (e.g., `memories/analysis/domain-model.md`)
- `[optional_instructions]`: Optional natural language string that gives the AI more context or specifies what part of the current discussion should be added

## Purpose

Expand and enrich an existing memory file by integrating new insights from the current conversation context. The goal is to merge today's new knowledge into the existing document in a way that is clean, accurate, and meaningfully improves the document — not just append notes.

## Instructions for AI Assistant

1. **Load the memory file** indicated by `$MEMORY_FILE`.
   - Understand its content, structure, tone, and purpose.

2. **Read the current discussion context** in this conversation.
   - This is the new information to incorporate into the memory file.

3. **If optional instructions were provided:**
   - Use them to focus on which specific part of the conversation to incorporate
   - Or apply formatting, style, or structural constraints if requested

4. **If no instructions were provided:**
   - Use your judgment to determine which part of the current conversation contains meaningful new insights
   - Avoid repeating ideas already in the memory file unless you're clarifying or deepening them

5. **Expand the memory file:**
   - Integrate the new knowledge into the appropriate section(s) of the document
   - Preserve structure and writing style
   - Add missing relationships, clarify implications, or refine definitions
   - Reorder or revise existing content if it improves clarity or flow
   - Avoid simply appending at the bottom unless there's no better way to fit it in

6. **Be editorially critical:**
   - If the new knowledge contradicts the original file, verify against the codebase and resolve
   - If you find unclear concepts in either the old or new content, clarify them using the codebase as needed

7. **Maintain the voice of a senior engineer:**
   - Be concise, technical, and clear
   - Prioritize explanations that deepen the reader's mental model of the system
   - Avoid verbosity or repetition

8. **Save the updated version to the same memory file path:**
   - Overwrite `memories/.../$MEMORY_FILE` with the improved version
   - Add a comment block or footer indicating:
     - Timestamp of expansion
     - Conversation reference (e.g., "Expanded based on conversation from [date/time]")
     - If possible, a short summary of what was added or clarified

## Expected Outcome

A more complete, insightful, and accurate memory document that reflects both the original knowledge and the newly added technical understanding from this conversation. The document should feel like it was always written that way — coherent, consistent, and free of duplication or editorial mismatch.