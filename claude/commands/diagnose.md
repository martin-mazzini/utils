---
description: Deep error analysis and root cause diagnosis
---

## Parameters
- `description`: Error context, stack trace, error logs, or any relevant information about the error

## Task
You are tasked with performing a deep, analytical diagnosis of an error. Think methodically and trace through the code systematically to identify the root cause.

### Phase 1: Error Identification
From the provided error information, extract and highlight ONLY the most relevant error lines. The user may provide a large blob of logs - you must zoom in on the actual error messages, stack traces, or failure points.

**Output format:**
```
RELEVANT ERROR LINES:
[Extract only the key error messages, stack traces, or failure indicators]
```

### Phase 2: Code Location Analysis
Identify the exact locations in the codebase where the error originates. Trace through the stack trace or error messages to find:
- The specific line where the program panicked/errored
- The query that failed (if applicable)
- The function call chain leading to the error

**Output format:**
```
KEY CODE LOCATIONS:
- Primary error location: [file_path:line_number] - [brief description]
- Related locations: [file_path:line_number] - [brief description]
```

### Phase 3: Root Cause Analysis
This is the MOST CRITICAL phase. Think deeply and logically about:
1. **Immediate cause**: What specific condition triggered the error?
2. **Preconditions**: What assumptions or preconditions were violated?
3. **State analysis**: How did the program get into this error state?
4. **High-level cause**: What's the underlying issue (e.g., invalid database record, network failure, race condition)?

For each assertion or conclusion, explicitly state your confidence level:
- **[THEORETICAL]**: Based on general patterns, but not specific to this code
- **[PROBABLE]**: Strong evidence suggests this, but not conclusive
- **[CERTAIN]**: Direct evidence from error messages/code confirms this

**Output format:**
```
CAUSE OF ERROR:
Immediate cause: [What specifically triggered the error]
Unmet preconditions: [What assumptions were violated]
Program state path: [How the program reached this error state]
High-level root cause: [The underlying issue]

Confidence: [THEORETICAL/PROBABLE/CERTAIN] - [Explanation of confidence level]
```

### Phase 4: Solution Proposal
WITHOUT WRITING ANY CODE, propose a solution based on your analysis. Be specific about what needs to change and why.

**Output format:**
```
POTENTIAL SOLUTION:
[Detailed description of what needs to be fixed and why]

Implementation approach: [High-level steps without actual code]
Risk assessment: [Any potential side effects or considerations]
```

### Phase 5: User Confirmation
After presenting your analysis, ask:
```
Do you agree with this diagnosis and would you like me to implement the proposed solution?
```

## CRITICAL RULES
1. **NO CODING** during the diagnosis phase - only analysis
2. **Be explicit about certainty levels** - distinguish between assumptions and facts
3. **Focus on the actual error** - don't get distracted by unrelated log entries
4. **Think systematically** - trace the execution path that leads to the error
5. **Only proceed to coding if the user explicitly confirms** they want the solution implemented

## Example Usage
User: /diagnose "TypeError: Cannot read property 'name' of undefined at UserService.js:45"

Your response would analyze:
- The specific line UserService.js:45
- What object is undefined and why
- How the code execution reached that point with an undefined value
- Whether it's a data issue, logic error, or missing validation
- A solution proposal (without code)
- Request for confirmation before coding