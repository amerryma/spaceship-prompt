#
# Docker
#
# Docker automates the repetitive tasks of setting up development environments
# Link: https://www.docker.com

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_DOCKER_SHOW="${SPACESHIP_DOCKER_SHOW=true}"
SPACESHIP_DOCKER_ASYNC="${SPACESHIP_DOCKER_ASYNC=true}"
SPACESHIP_DOCKER_PREFIX="${SPACESHIP_DOCKER_PREFIX="on "}"
SPACESHIP_DOCKER_SUFFIX="${SPACESHIP_DOCKER_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_DOCKER_SYMBOL="${SPACESHIP_DOCKER_SYMBOL="🐳"}"
SPACESHIP_DOCKER_COLOR="${SPACESHIP_DOCKER_COLOR="cyan"}"
SPACESHIP_DOCKER_VERBOSE="${SPACESHIP_DOCKER_VERBOSE=false}"

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/sections/docker_context.zsh"
spaceship::precompile "$SPACESHIP_ROOT/sections/docker_context.zsh"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show Docker status
spaceship_docker() {
  [[ $SPACESHIP_DOCKER_SHOW == false ]] && return

  spaceship::exists docker || return

  local output=""

  # Always show the Docker symbol
  output+="$SPACESHIP_DOCKER_SYMBOL"

  # Check for Docker-specific files to decide whether to show the Docker version
  local docker_project_globs=('Dockerfile' '.devcontainer/Dockerfile' 'docker-compose.y*ml')
  local is_docker_project="$(spaceship::upsearch Dockerfile $docker_project_globs)"

  if [[ -n "$is_docker_project" || -f /.dockerenv || -n "$(spaceship_docker_context)" ]]; then
    # Get the Docker version
    local docker_version=$(docker version -f "{{.Server.Version}}" 2>/dev/null)
    if [[ $? -eq 0 && -n $docker_version ]]; then
      [[ $SPACESHIP_DOCKER_VERBOSE == false ]] && docker_version=${docker_version%-*}
      output+="v${docker_version}"
    fi
  fi

  # Get the number of running containers
  local container_count=$(docker ps -q | wc -l)
  if [[ $container_count -gt 0 ]]; then
    output+=" [$container_count]"
  else
    return
  fi

  spaceship::section \
    --color "$SPACESHIP_DOCKER_COLOR" \
    --prefix "$SPACESHIP_DOCKER_PREFIX" \
    --suffix "$SPACESHIP_DOCKER_SUFFIX" \
    "$output"
}
