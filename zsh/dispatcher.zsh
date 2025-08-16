#!/bin/bash
# Dispatcher Functions - Generic service orchestration

# initPorts() - Sets up port configuration for the current or specified service
initPorts() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # First argument could be repo name or port config
  # Second argument is definitely port config if present
  local arg1="$1"
  local arg2="$2"
  local repo_name
  local port_config
  
  # Determine if arg1 is a repo name or port config
  if [[ -n "$arg2" ]]; then
    # If arg2 exists, arg1 is repo name and arg2 is port config
    repo_name="$arg1"
    port_config="$arg2"
  elif [[ "$arg1" == *":"* ]]; then
    # If arg1 contains colon, it's a port config
    repo_name="$(get_base_repo_name)"
    port_config="$arg1"
  else
    # Otherwise arg1 is repo name (or empty)
    repo_name="${arg1:-$(get_base_repo_name)}"
    port_config=""
  fi
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🔧 Setting up ports for $repo_name..."
  
  # Source services.sh to get the init functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      initPorts-my-app-service "$port_config"
      ;;
    *)
      echo "⚠️  No port configuration defined for $repo_name"
      ;;
  esac
}

# install() - Installs dependencies for the current or specified service
install() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # Auto-detect repo if not provided, using base repo name for worktrees
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "📦 Installing dependencies for $repo_name..."
  
  # Source services.sh to get the install functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      install-my-app-service
      ;;
    *)
      echo "⚠️  No install configuration defined for $repo_name"
      ;;
  esac
}

# build() - Builds the current or specified service including Docker services and migrations
build() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # Auto-detect repo if not provided, using base repo name for worktrees
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🔨 Building $repo_name..."
  
  # Source services.sh to get the build functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      build-my-app-service
      ;;
    *)
      echo "⚠️  No build configuration defined for $repo_name"
      ;;
  esac
}

# run() - Runs the development server for the current or specified service with hot reload
run() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # Auto-detect repo if not provided, using base repo name for worktrees
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🚀 Running $repo_name..."
  
  # Source services.sh to get the run functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      run-my-app-service
      ;;
    *)
      echo "⚠️  No run configuration defined for $repo_name"
      ;;
  esac
}

# init() - Full initialization: ports + install + build for the current or specified service
init() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # Auto-detect repo if not provided, using base repo name for worktrees
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  # Source services.sh to get the init functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      init-my-app-service
      ;;
    *)
      echo "⚠️  No init configuration defined for $repo_name"
      echo "   Falling back to generic init..."
      echo ""
      initPorts "$repo_name" || return 1
      echo ""
      install "$repo_name" || return 1
      echo ""
      build "$repo_name" || return 1
      echo ""
      echo "✅ $repo_name initialization complete!"
      ;;
  esac
}

# Docker Compose Management Dispatchers

# docker-run() - Starts Docker services in detached mode (docker compose up -d)
docker-run() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🚀 Starting $repo_name Docker services..."
  
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      docker-run-my-app-service
      ;;
    *)
      echo "⚠️  No docker-run configuration defined for $repo_name"
      ;;
  esac
}

# docker-stop() - Stops Docker services while preserving containers (docker compose stop)
docker-stop() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "⏹️  Stopping $repo_name services..."
  
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      stop-my-app-service
      ;;
    *)
      echo "⚠️  No stop configuration defined for $repo_name"
      ;;
  esac
}

# docker-restart() - Restarts Docker services without rebuilding (docker compose restart)
docker-restart() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🔄 Restarting $repo_name services..."
  
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      restart-docker-my-app-service
      ;;
    *)
      echo "⚠️  No restart configuration defined for $repo_name"
      ;;
  esac
}

# docker-build-images() - Builds Docker images without starting containers (docker compose build)
docker-build-images() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🏗️  Building images for $repo_name..."
  
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      build-images-my-app-service
      ;;
    *)
      echo "⚠️  No build-images configuration defined for $repo_name"
      ;;
  esac
}

# docker-rebuild() - Rebuilds images and recreates containers (docker compose up -d --build --force-recreate)
docker-rebuild() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "♻️  Rebuilding $repo_name (images and containers)..."
  
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      rebuild-my-app-service
      ;;
    *)
      echo "⚠️  No rebuild configuration defined for $repo_name"
      ;;
  esac
}

# docker-delete() - Nuclear cleanup: removes containers, volumes, networks, and images (docker compose down -v)
docker-delete() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "🗑️  Deleting $repo_name stack completely..."
  
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      delete-my-app-service
      ;;
    *)
      echo "⚠️  No delete configuration defined for $repo_name"
      ;;
  esac
}

# rebuild() - Rebuilds the service (rebuild + rerun) for the current or specified service
rebuild() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # Auto-detect repo if not provided, using base repo name for worktrees
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "♻️  Rebuilding and rerunning $repo_name..."
  
  # Source services.sh to get the rebuild functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      restart-my-app-service
      ;;
    *)
      echo "⚠️  No rebuild configuration defined for $repo_name"
      ;;
  esac
}

# nuke-and-rebuild() - Nuclear rebuild: clean install from scratch, then build and run
nuke-and-rebuild() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  # Auto-detect repo if not provided, using base repo name for worktrees
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not inside a Git repository"
    return 1
  fi
  
  echo "☢️  Nuking and rebuilding $repo_name from scratch..."
  
  # Source services.sh to get the nuke functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      nuke-my-app-service
      ;;
    *)
      echo "⚠️  No nuke-and-rebuild configuration defined for $repo_name"
      ;;
  esac
}

# randomize() - Randomizes ports for the current service
# Purpose: Generate random ports for existing .env files without recreating them
# How it works:
#   - Auto-detects current repository
#   - Calls service-specific randomize function
#   - Only modifies UI/server ports, never database ports
#   - Assumes .env files already exist
# Dependencies:
#   - Service-specific randomize functions in service files
#   - get_free_port function from utils.zsh
#   - writeRandomPort function from project.zsh
# Use case: Quickly randomize ports for existing service configurations
randomize() {
  # Source utils to get helper functions
  source ~/.config/zsh/utils.zsh
  
  local repo_name="${1:-$(get_base_repo_name)}"
  
  if [ -z "$repo_name" ]; then
    echo "❌ Not in a Git repository or unable to detect repo name"
    return 1
  fi
  
  echo "🎲 Randomizing ports for $repo_name..."
  
  # Source services.sh to get the randomize functions
  local services_config="$HOME/.config/zsh/services.sh"
  if [ -f "$services_config" ]; then
    source "$services_config"
  else
    echo "❌ Services config not found at $services_config"
    return 1
  fi
  
  case "$repo_name" in
    "my-app-service")
      randomize-my-app-service
      ;;
    *)
      echo "⚠️  No randomize configuration defined for $repo_name"
      ;;
  esac
}