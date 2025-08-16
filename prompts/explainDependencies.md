Map out external systems this project depends on or integrates with.

Usage: /explainDependencies $ARGUMENTS

Instructions for AI Assistant:
1. Identify all external dependencies and integrations:
   - Databases (PostgreSQL, MongoDB, Redis, etc.)
   - Caches (Redis, Memcached, in-memory)
   - Message queues or event buses (Kafka, RabbitMQ, NATS, SQS)
   - External APIs or third-party services
   - File storage systems (S3, local filesystem)
   - Authentication providers (OAuth, LDAP, SAML)
2. For each dependency:
   - Purpose and why it's needed
   - Connection configuration and credentials management
   - Fallback or retry strategies
   - Health checks and circuit breakers
   - Version or compatibility requirements
3. Analyze:
   - Whether integrations are abstracted behind adapters or tightly coupled
   - Dependency injection patterns
   - Configuration management approach
   - Environment-specific dependencies
   - Optional vs. required dependencies
4. Document:
   - Dependency graph showing relationships
   - Critical path dependencies
   - Potential single points of failure
   - Data flow between systems
   - Synchronous vs. asynchronous interactions
5. If $ARGUMENTS highlights specific systems, provide deeper analysis
6. Note any dependency risks or technical debt
7. Identify opportunities for decoupling or abstraction

The output should reveal what the service needs to run and communicate with, both internally and externally.

8. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/07-dependencies.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file