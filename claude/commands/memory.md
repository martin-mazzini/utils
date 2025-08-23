Create a comprehensive memory file documenting a specific topic from our current conversation.

Usage: /memory [topic-name] [description]

Instructions for Claude:
1. Use only the context and information already discovered in our current conversation
2. Create a well-structured markdown file about the topic in [description] based on our current conversation in `memories/[topic-name].md` within the current working directory (the root of the git repository where Claude is being launched from)
3. Focus the documentation on the specific topic mentioned in [description] - if multiple topics have been discussed, concentrate only on the described topic
4. If [description] contains additional instructions beyond topic specification, follow those instructions as well
5. Prioritize completeness and clarity over brevity - ensuring all important details are captured
6. Structure the content logically with proper headings, code examples, and cross-references
7. Include all important details so that future-Claude can fully understand the topic without additional exploration
8. Do not perform any additional research or exploration - only document what has already been discussed

The memory file should be comprehensive enough that Claude can understand the topic completely from the documentation alone.