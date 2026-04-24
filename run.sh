#!/bin/bash

# Default variables
PROFILE=""
COMPOSE_FILE="docker-compose.yml"
SERVICE_NAME=""

# Parse input parameters
for arg in "$@"; do
    case $arg in
        foxy)
            PROFILE="foxy"
            SERVICE_NAME="go2-foxy"
            ;;
        humble)
            PROFILE="humble"
            SERVICE_NAME="go2-humble"
            ;;
        --nogpu)
            COMPOSE_FILE="docker-compose-nogpu.yml"
            ;;
        *)
            echo "Error: Unknown argument '$arg'"
            echo "Usage: $0 [foxy|humble] [--nogpu]"
            exit 1
            ;;
    esac
done

# Check if a valid profile was provided
if [ -z "$PROFILE" ]; then
    echo "Error: You must specify a profile (foxy or humble)."
    echo "Usage: $0 [foxy|humble] [--nogpu]"
    exit 1
fi

echo "========================================"
echo "Profile      : $PROFILE"
echo "Compose File : $COMPOSE_FILE"
echo "Service      : $SERVICE_NAME"
echo "========================================"

# Check if the container is already running
RUNNING=$(docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" ps -q "$SERVICE_NAME")

if [ -z "$RUNNING" ]; then
    # 1. Build the selected profile
    echo "Container not running. Building the Docker image..."
    docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" build

    # 2. Run the container in detached mode
    echo "Starting the container..."
    xhost +local:docker
    docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" up -d
else
    echo "Container is already running. Skipping build and start..."
fi

# 3. Enter the interactive bash shell
echo "Attaching to interactive bash shell..."
docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" exec "$SERVICE_NAME" /bin/bash -lc "\
source /opt/ros/\${ROS_DISTRO}/setup.bash; \
if [ -f /Ros2-go2/install/setup.bash ]; then source /Ros2-go2/install/setup.bash; fi; \
if [ -f /ws/install/setup.bash ]; then source /ws/install/setup.bash; fi; \
if [ -f /Go2_navigation/install/setup.bash ]; then source /Go2_navigation/install/setup.bash; fi; \
exec /bin/bash"
