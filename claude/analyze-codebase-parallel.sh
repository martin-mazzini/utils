#!/bin/bash
# Script to run all explain commands in parallel

echo "Running comprehensive codebase analysis in parallel..."
mkdir -p memories/analysis

# Function to run command and report completion
run_analysis() {
    local name=$1
    local command=$2
    local output=$3
    echo "Starting: $name..."
    claude -p "$command" > "$output" 2>&1
    echo "Completed: $name"
}

# Run all commands in parallel
run_analysis "Project Overview" "/explainOverview" "memories/analysis/01-overview.md" &
run_analysis "Setup" "/explainSetup" "memories/analysis/02-setup.md" &
run_analysis "Tech Stack" "/explainStack" "memories/analysis/03-stack.md" &
run_analysis "Infrastructure" "/explainInfra" "memories/analysis/04-infrastructure.md" &
run_analysis "Architecture" "/explainArchitecture" "memories/analysis/05-architecture.md" &
run_analysis "API" "/explainAPI" "memories/analysis/06-api.md" &
run_analysis "Dependencies" "/explainDependencies" "memories/analysis/07-dependencies.md" &
run_analysis "Data Flow" "/explainDataFlow" "memories/analysis/08-dataflow.md" &
run_analysis "Testing" "/explainTesting" "memories/analysis/09-testing.md" &
run_analysis "Observability" "/explainObservability" "memories/analysis/10-observability.md" &
run_analysis "Domain Concepts" "/explainDomain" "memories/analysis/11-domain.md" &
run_analysis "Data Models" "/explainModels" "memories/analysis/12-models.md" &

# Wait for all background jobs to complete
echo "Waiting for all analyses to complete..."
wait

echo "All analyses complete! Results saved in memories/analysis/"
echo "Run 'claude -p \"/memory aggregate-analysis Review all files in memories/analysis/ and create a comprehensive summary\"' to generate final report"