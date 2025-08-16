Describe the core data model and domain schema of the system.

Usage: /explainModels $ARGUMENTS

Instructions for AI Assistant:
1. Identify main entities and models:
   - Database schemas and migrations
   - ORM models or entity definitions
   - API request/response schemas
   - Domain objects and their boundaries
   - Configuration or metadata models
2. Document model structure:
   - Key attributes and their types
   - Required vs. optional fields
   - Default values and constraints
   - Computed or derived properties
   - Audit fields (created_at, updated_by)
3. Map relationships:
   - One-to-one, one-to-many, many-to-many
   - Foreign keys and join tables
   - Embedded documents or denormalization
   - Cascade behaviors (delete, update)
   - Circular dependencies
4. Analyze data patterns:
   - Aggregates and their roots
   - View models and projections
   - DTOs and transformation layers
   - Event sourcing or CQRS patterns
   - Caching strategies for models
5. Document validation and invariants:
   - Field-level validations
   - Cross-field constraints
   - Business rule enforcement
   - State transition rules
   - Uniqueness constraints
6. Examine data lifecycle:
   - How entities are created
   - Update patterns and versioning
   - Soft deletes vs. hard deletes
   - Archival strategies
   - Data retention policies
7. If $ARGUMENTS specifies particular models, provide detailed analysis
8. Create entity relationship diagrams (in text/ASCII)
9. Note any modeling anti-patterns or improvements

The output should provide an intuitive grasp of data structure, constraints, and domain complexity.

10. Memory Management:
    - If $ARGUMENTS contains "no memory", just display the analysis
    - Otherwise (default), save the analysis to memories/analysis/12-models.md
    - Create the memories/analysis directory if it doesn't exist
    - Include timestamp and codebase name in the memory file