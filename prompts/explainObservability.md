Analyze how this system is monitored and operated in production.

Usage: /explainObservability $ARGUMENTS

Instructions for AI Assistant:
1. Identify observability and monitoring tools:
   - Metrics collection (Prometheus, StatsD, CloudWatch)
   - Log aggregation (ELK, Splunk, CloudWatch Logs)
   - Distributed tracing (Jaeger, Zipkin, X-Ray)
   - Error tracking (Sentry, Rollbar, Bugsnag)
   - APM solutions (DataDog, New Relic, AppDynamics)
2. Analyze metrics implementation:
   - What metrics are exposed (counters, gauges, histograms)
   - Business metrics vs. technical metrics
   - Custom metrics and their purpose
   - Metric naming conventions
   - Cardinality considerations
3. Examine logging practices:
   - Log levels and when they're used
   - Structured logging format
   - Correlation IDs and request tracing
   - Sensitive data handling
   - Log volume and retention
4. Review health and status mechanisms:
   - Health check endpoints
   - Readiness/liveness probes
   - Status pages or dashboards
   - Dependency health checks
   - Graceful degradation
5. Document alerting and incident response:
   - Alert rules and thresholds
   - Escalation policies
   - Runbooks or playbooks
   - On-call procedures
   - Post-mortem practices
6. Trace production debugging capabilities:
   - How to follow a request through the system
   - Debug endpoints or flags
   - Performance profiling tools
   - Memory/CPU analysis
7. If $ARGUMENTS specifies particular aspects, focus analysis there
8. Note gaps in observability coverage

The output should reveal how maintainers gain visibility into system behavior and diagnose issues.

9. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/10-observability.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file