Explain exactly how to set up and run this project in a local dev environment.

Usage: /explainSetup $ARGUMENTS

Instructions for AI Assistant:
1. Examine the codebase for setup documentation, configuration files, and build scripts
2. Identify if it uses Docker or Docker Compose
3. Determine which components (DB, queues, services) are containerized vs. local
4. List tools or languages needed (e.g., Node, Go, pnpm, Java)
5. Find environment variables or config files required and their locations
6. Create a step-by-step guide with specific commands (in order) to get the system running end-to-end
7. Include:
   - Prerequisites and system requirements
   - Installation steps for dependencies
   - Configuration setup (env vars, config files)
   - Database migrations or seed data
   - How to start all services
   - How to verify everything is working
   - Common troubleshooting tips
8. If $ARGUMENTS contains specific aspects to focus on, prioritize those
9. Present as a bulletproof local setup guide that combines README info with tribal knowledge

The guide should enable someone to go from zero to a fully running local environment without assistance.

10. Memory Management:
    - If $ARGUMENTS contains "no memory", just display the analysis
    - Otherwise (default), save the analysis to memories/analysis/02-setup.md
    - Create the memories/analysis directory if it doesn't exist
    - Include timestamp and codebase name in the memory file