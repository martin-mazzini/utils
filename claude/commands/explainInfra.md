Describe the infrastructure setup based on repository and deployment-related files.

Usage: /explainInfra $ARGUMENTS

Instructions for Claude:
1. Search for infrastructure and deployment configuration:
   - Look for folders like /infra, /charts, /terraform, /.github/workflows
   - Find Dockerfiles, docker-compose files, k8s manifests
   - Identify IaC files (Terraform, CloudFormation, Pulumi)
   - Check for CI/CD configuration files
2. Determine:
   - Where and how the system is deployed (Kubernetes, ECS, Lambda, etc.)
   - IaC tools in use (Terraform, Helm, CDK)
   - CI/CD pipeline setup (GitHub Actions, CircleCI, Jenkins, Argo)
   - Environment management (dev, staging, prod)
   - Secrets management approach
   - Monitoring and observability integrations
3. Analyze:
   - Deployment strategies (blue-green, canary, rolling)
   - Service discovery and load balancing
   - Database and storage configuration
   - Network architecture and security groups
   - Auto-scaling policies
4. If $ARGUMENTS specifies particular aspects, focus analysis there
5. Infer real-world deployment setup from config and code clues
6. Document:
   - Infrastructure architecture diagram (in text)
   - Deployment flow
   - Key infrastructure components
   - Security and compliance considerations

The output should reveal how the application runs in production environments.

7. Memory Management:
   - If $ARGUMENTS contains "no memory", just display the analysis
   - Otherwise (default), save the analysis to memories/analysis/04-infrastructure.md
   - Create the memories/analysis directory if it doesn't exist
   - Include timestamp and codebase name in the memory file