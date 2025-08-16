Aggregate multiple analysis documents into a single, authoritative technical reference.

Usage: /aggregate $ARGUMENTS
$ARGUMENTS is a list of file paths (e.g., memories/analysis/01-overview.md) all referring to the same codebase from different perspectives.

Instructions for AI Assistant:

Parse Arguments
Interpret $ARGUMENTS as a list of memory files to load.
Files may be nested in subdirectories under the memories/ folder.

Analyze All Documents
For each document:

Extract the key technical points.

Identify overlaps, contradictions, and unique insights.

Understand how each piece fits into the broader system.

Look for different business domains (e.g., Payments vs Notifications), different layers (e.g., frontend vs backend), or different abstraction levels (e.g., flow vs service vs code structure).

Validate and Resolve Ambiguities
When contradictions, vagueness, or questionable claims are found:

Inspect the actual codebase to determine what is correct.

Clearly identify which document (if any) reflects reality.

Use the source code as the ground truth.

Produce the Aggregated Output
Generate a new, standalone document that:

Synthesizes all valid insights into a coherent, non-redundant narrative

Preserves important technical details but avoids repetition

Resolves contradictions with facts from code

Makes implicit relationships between concepts explicit

Fills gaps by directly reading the codebase when necessary

Structure and Format the Output
Use formatting that improves clarity and utility:

Headings and section hierarchy

ASCII or text-based diagrams when helpful

Tables for summarizing or comparing elements

Code snippets to illustrate key behaviors

Cross-references between related sections

Write with the Voice of a Senior Engineer
The tone should:

Be precise, technical, and concise

Focus on clarity and insight, not verbosity

Explain the "why" behind decisions

Highlight subtle connections or coupling

Call out design flaws, tech debt, or inconsistencies where relevant

Save the Output
Save the result as a new file in memories/aggregated/{descriptive-name}.md
You choose the name based on what the document covers.
At the bottom of the file, include:

A generation timestamp

The list of source documents used

A summary of any codebase files or locations that were inspected during validation

Expected Outcome:
A high-quality, deeply insightful internal reference document that provides a clearer understanding of the system than any individual source. It should feel like a trusted teammate has stitched together everything that matters and explained it cleanly.

