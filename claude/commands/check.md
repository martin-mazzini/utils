Verify if a claim about the codebase is true, partially true, or false.

Usage: /check "$CLAIM"

Example: /check "The paymentRepository is currently not being used"

Instructions for Claude:
1. Parse the claim - a factual statement about any aspect of the codebase:
   - Code structure, data flow, business logic
   - Architectural patterns, dependencies, usage
   - Testing coverage, tooling, configurations
   - Unused code, implementation gaps

2. Search thoroughly for evidence:
   - Find all relevant files and code
   - Check imports, references, implementations
   - Verify actual usage patterns

3. Return one verdict:
   - ✅ True
   - ⚠️ Partially True
   - ❌ False

4. Output format:
   ```
   ### Claim:
   "[exact claim]"
   
   ### Verdict:
   [verdict]
   
   ### Evidence:
   - Show specific file paths with clickable links: path/to/file.ts:lineNumber
   - Include relevant code snippets
   - List all supporting or contradicting evidence
   
   ### Summary:
   [Brief explanation of findings]
   ```

5. Rules:
   - Never bluff - if uncertain, say so
   - Show real paths and actual code
   - For "Partially True", explain what's true vs false
   - Think from first principles when needed