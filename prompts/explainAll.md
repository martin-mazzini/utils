Run all individual explain commands and aggregate their results into a comprehensive report.

Usage: /explainAll $ARGUMENTS

Instructions for AI Assistant:
1. Execute each explain command sequentially:
   - /explainOverview
   - /explainSetup
   - /explainStack
   - /explainInfra
   - /explainArchitecture
   - /explainAPI
   - /explainDependencies
   - /explainDataFlow
   - /explainTesting
   - /explainObservability
   - /explainDomain
   - /explainModels
2. Store each command's output in a memories/analysis/ folder with descriptive filenames
3. After all commands complete, create a consolidated report that:
   - Includes an executive summary
   - Organizes all findings by category
   - Cross-references related information
   - Highlights key insights and patterns
   - Identifies gaps or inconsistencies
   - Provides actionable recommendations
4. Save the final aggregated report as memories/analysis/complete-codebase-analysis.md
5. If $ARGUMENTS specifies particular areas to emphasize, ensure those get priority in the summary

The final output should provide both the individual detailed analyses and a cohesive overview.