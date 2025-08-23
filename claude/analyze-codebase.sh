#!/bin/bash
# Script to run all explain commands and aggregate results

echo "Running comprehensive codebase analysis..."
mkdir -p memories/analysis

# Run each command and save output
echo "1/12: Analyzing project overview..."
claude -p "/explainOverview" > memories/analysis/01-overview.md

echo "2/12: Analyzing setup..."
claude -p "/explainSetup" > memories/analysis/02-setup.md

echo "3/12: Analyzing tech stack..."
claude -p "/explainStack" > memories/analysis/03-stack.md

echo "4/12: Analyzing infrastructure..."
claude -p "/explainInfra" > memories/analysis/04-infrastructure.md

echo "5/12: Analyzing architecture..."
claude -p "/explainArchitecture" > memories/analysis/05-architecture.md

echo "6/12: Analyzing API..."
claude -p "/explainAPI" > memories/analysis/06-api.md

echo "7/12: Analyzing dependencies..."
claude -p "/explainDependencies" > memories/analysis/07-dependencies.md

echo "8/12: Analyzing data flow..."
claude -p "/explainDataFlow" > memories/analysis/08-dataflow.md

echo "9/12: Analyzing testing..."
claude -p "/explainTesting" > memories/analysis/09-testing.md

echo "10/12: Analyzing observability..."
claude -p "/explainObservability" > memories/analysis/10-observability.md

echo "11/12: Analyzing domain concepts..."
claude -p "/explainDomain" > memories/analysis/11-domain.md

echo "12/12: Analyzing data models..."
claude -p "/explainModels" > memories/analysis/12-models.md

echo "Analysis complete! Results saved in memories/analysis/"
echo "Run 'claude -p \"/memory aggregate-analysis Review all files in memories/analysis/ and create a comprehensive summary\"' to generate final report"