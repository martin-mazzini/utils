Create a comprehensive implementation plan for a feature based on its description file.

Usage: /planFeature [feature-filename]

Instructions for AI Assistant:
1. Read the feature description file from `./memories/features/[feature-filename].md`
2. Look for the "Prerequisite read:" section at the top of the feature file and read ALL listed documents. Memories are located in the `./memories` folder, implementation Plans of past related features are located in the `./memories/plans`, Feature description of past related features are located in `./memories/features`, PR (actual implementation done) of past related features are located in `./memories/prs`.
3. Think through the implementation approach based on the feature description and prerequisite context.
4. Read relevant code files to understand the current codebase structure and patterns
5. Do NOT write any code during this planning phase - focus only on understanding and planning
6. Use "think", "think hard", "think harder", or "ultrathink" to trigger extended thinking mode for thorough evaluation
7. Create a detailed implementation plan and save it to `./memories/plans/[feature-name].md`
8. Structure the plan with:
   - Prerequisite context: Based on all the context you gathered from the prerequisite reads and your investigation of the codebase, create a comprehensive summary of all the context to guide the implementation without requiring any extra reads.
   - Summary of the feature
   - Prerequisites and dependencies
   - Implementation steps with clear ordering
   - File locations and components to modify/create
   - Existing patterns to follow
   - Potential challenges and considerations 
9. Make the plan comprehensive enough to guide implementation without requiring additional planning

The plan should serve as a complete roadmap for implementing the described feature.