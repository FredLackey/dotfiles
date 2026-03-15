# dp - Display running Docker containers in a compact table
#
# Usage:
#   dp

function dp {
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"
}
