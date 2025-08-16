Identify and explain the core domain concepts and ubiquitous language in this project.

Usage: /explainDomain $ARGUMENTS

Instructions for AI Assistant:
1. Identify core business concepts:
   - Scan for domain-specific terms in code, comments, and documentation
   - Look for recurring business terms (Order, Customer, Policy, etc.)
   - Find industry-specific vocabulary
   - Note concepts that appear across multiple layers
2. Analyze domain modeling:
   - Where domain concepts are defined (models, types, interfaces)
   - How they're represented in code vs. database vs. API
   - Consistency of naming across layers
   - Evolution of domain concepts over time
3. Examine Domain-Driven Design patterns:
   - Bounded contexts and their boundaries
   - Aggregates and aggregate roots
   - Value objects vs. entities
   - Domain events and commands
   - Repositories and domain services
4. Document the ubiquitous language:
   - Create a glossary of domain terms
   - Show how business language maps to code
   - Identify naming inconsistencies or drift
   - Note where technical terms leak into domain
5. Analyze domain rules and invariants:
   - Business rules embedded in code
   - Validation logic and constraints
   - State machines and workflows
   - Domain-specific calculations
6. Map concept relationships:
   - How domain concepts relate to each other
   - Ownership and lifecycle dependencies
   - Transactional boundaries
   - Event flows between concepts
7. If $ARGUMENTS highlights specific domain areas, deep dive there
8. Note alignment between code and business understanding

The output should help readers internalize the mental map of the problem space and business language.

9. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/11-domain.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file