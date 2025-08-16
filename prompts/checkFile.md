Check the accuracy of documentation against the actual codebase.

Usage: /checkFile $ARGUMENTS

Instructions for AI Assistant:
1. Parse $ARGUMENTS to get the list of documents to verify
   - Files should be paths under the memories folder
   - If no files specified, prompt user to provide file paths
   
2. For each document provided:
   - Read the document thoroughly
   - Extract every factual claim about the codebase:
     - Function names and locations
     - API endpoints and behavior
     - Data flow descriptions
     - Service interactions
     - Configuration details
     - Business logic implementations
     - Architecture patterns
     - Dependencies and integrations
   
3. Verify each claim by inspecting the actual codebase:
   - Check if files/functions exist where claimed
   - Verify function signatures match descriptions
   - Confirm data flow paths are accurate
   - Validate service interactions
   - Check configuration values
   - Verify business logic implementations
   
4. Categorize each finding:
   - ✅ Fully accurate: Matches code exactly
   - ⚠️ Outdated/imprecise: Partially correct but needs update
   - ❌ Incorrect: False or misleading claim
   
5. Report findings in this exact format:
   - If all accurate: "All statements in the document are factually accurate and reflect the current state of the codebase."
   - If issues found, list each as:
     ```
     ❌ Inaccurate claim:
     > "[Quote the exact claim from document]"
     ✅ Reality in code:
     > [Describe what the code actually shows]
     ```
   
6. After listing all findings, ask:
   "Would you like me to update the document to reflect these corrections?"
   
7. Important rules:
   - Be strict but fair in verification
   - Quote claims exactly as written
   - Provide specific code evidence
   - Do not add editorial comments
   - Do not suggest improvements beyond accuracy
   - Focus only on factual correctness
   
The goal is pure verification against code truth, nothing more.