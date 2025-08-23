Describe how the codebase is organized and its architectural patterns.

Usage: /explainArchitecture $ARGUMENTS

Instructions for Claude:
1. Analyze the codebase structure to understand organization:
   - Top-level modules or directories and their roles
   - How business logic is layered (controller → service → repository)
   - Architectural patterns (modular, domain-driven, hexagonal, microservices)
   - Core domain logic vs. infrastructure/glue code locations
2. Examine:
   - Module boundaries and interfaces
   - Dependency directions and coupling
   - Separation of concerns
   - Design patterns in use (Factory, Observer, Strategy, etc.)
   - Cross-cutting concerns (logging, auth, validation)
3. Identify:
   - Entry points and bootstrapping
   - Configuration management approach
   - Error handling strategies
   - State management patterns
   - Communication patterns between components
4. Document:
   - High-level architecture diagram (in text/ASCII)
   - Key architectural decisions and trade-offs
   - How modules interact and depend on each other
   - Areas of technical debt or inconsistency
5. If $ARGUMENTS highlights specific concerns, address those in detail
6. Explain the mental model of the system and its separation of concerns
7. Note any architectural smells or improvement opportunities

The output should help developers understand the system's structure and design philosophy.

8. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/05-architecture.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file