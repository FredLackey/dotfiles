#!/bin/bash
# Initialize nginx configuration from template files.
#
# Usage:
#   nginx-init -d example.com -h http://127.0.0.1:3000 -f example.conf
#   nginx-init --api -d api.example.com -h http://127.0.0.1:8080 -f api.conf --link

nginx-init() {
    local usage="nginx-init [OPTIONS]

OPTIONS:
    -a, --api       Use nginx-docker-host-api.conf template
    -d, --domain    Domain name for server_name directive (can be used multiple times) (required)
    -h, --host      Upstream URL for proxy_pass directive (required)
    -f, --file      Output filename in /etc/nginx/sites-available (must end with .conf) (required)
    -l, --link      Create symbolic link in /etc/nginx/sites-enabled

EXAMPLES:
    nginx-init -d example.com -h http://127.0.0.1:3000 -f example.conf
    nginx-init -d example.com -d www.example.com -h http://127.0.0.1:3000 -f example.conf
    nginx-init --api -d api.example.com -h http://127.0.0.1:8080 -f api.conf --link"

    local use_api=false
    local domains=()
    local host=""
    local filename=""
    local create_link=false
    local sites_available="/etc/nginx/sites-available"
    local sites_enabled="/etc/nginx/sites-enabled"

    # Check if we have sudo access
    echo "This function requires sudo access to write to /etc/nginx/"
    if ! sudo -v; then
        echo "Error: sudo authentication failed"
        return 1
    fi

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--api)
                use_api=true
                shift
                ;;
            -d|--domain)
                domains+=("$2")
                shift 2
                ;;
            -h|--host)
                host="$2"
                shift 2
                ;;
            -f|--file)
                filename="$2"
                shift 2
                ;;
            -l|--link)
                create_link=true
                shift
                ;;
            --help)
                echo "$usage"
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "$usage"
                return 1
                ;;
        esac
    done

    # Show usage if no arguments provided
    if [[ ${#domains[@]} -eq 0 && -z "$host" && -z "$filename" ]]; then
        echo "$usage"
        return 0
    fi

    # Validate required arguments
    if [[ ${#domains[@]} -eq 0 ]]; then
        echo "Error: At least one domain is required (-d or --domain)"
        return 1
    fi

    if [[ -z "$host" ]]; then
        echo "Error: Host URL is required (-h or --host)"
        return 1
    fi

    if [[ -z "$filename" ]]; then
        echo "Error: Filename is required (-f or --file)"
        return 1
    fi

    if [[ ! "$filename" =~ \.conf$ ]]; then
        echo "Error: Filename must end with .conf"
        return 1
    fi

    # Check if sites-available directory exists
    if [[ ! -d "$sites_available" ]]; then
        echo "Error: Directory $sites_available does not exist"
        return 1
    fi

    local output_file="$sites_available/$filename"
    local domain_string
    domain_string=$(printf "%s " "${domains[@]}")
    domain_string="${domain_string% }"

    echo "Creating nginx configuration..."
    echo "Domains: $domain_string"
    echo "Host: $host"
    echo "Output: $output_file"

    # Create basic nginx config
    sudo tee "$output_file" > /dev/null << EOF
server {
    listen 80;
    server_name $domain_string;

    location / {
        proxy_pass $host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    echo "Configuration file created successfully"

    # Create symbolic link if requested
    if [[ "$create_link" == true ]]; then
        if [[ ! -d "$sites_enabled" ]]; then
            echo "Error: Directory $sites_enabled does not exist"
            return 1
        fi

        local link_path="$sites_enabled/$filename"

        if [[ -L "$link_path" ]]; then
            sudo rm "$link_path"
        fi

        sudo ln -s "$output_file" "$link_path"
        echo "Symbolic link created: $link_path"
    fi

    echo "Done!"
}
