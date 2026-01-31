#!/bin/bash
# Install SSL certificates using certbot for nginx.
#
# Usage:
#   certbot-init -d example.com -e admin@example.com
#   certbot-init -d example.com -d www.example.com -e admin@example.com

certbot-init() {
    local usage="certbot-init [OPTIONS]

OPTIONS:
    -d, --domain    Domain name for SSL certificate (can be used multiple times) (required)
    -e, --email     Email address for Let's Encrypt registration (required)

EXAMPLES:
    certbot-init -d example.com -e admin@example.com
    certbot-init -d example.com -d www.example.com -e admin@example.com"

    local domains=()
    local email=""

    # Show usage if no arguments provided
    if [[ $# -eq 0 ]]; then
        echo "$usage"
        return 0
    fi

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                if [[ -z "$2" || "$2" == -* ]]; then
                    echo "Error: Domain value required after -d/--domain"
                    return 1
                fi
                domains+=("$2")
                shift 2
                ;;
            -e|--email)
                if [[ -z "$2" || "$2" == -* ]]; then
                    echo "Error: Email value required after -e/--email"
                    return 1
                fi
                email="$2"
                shift 2
                ;;
            --help)
                echo "$usage"
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ ${#domains[@]} -eq 0 ]]; then
        echo "Error: At least one domain is required (-d or --domain)"
        return 1
    fi

    if [[ -z "$email" ]]; then
        echo "Error: Email address is required (-e or --email)"
        return 1
    fi

    # Validate email format
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "Error: Invalid email format: $email"
        return 1
    fi

    echo "This function requires sudo access to install certbot and configure SSL"
    if ! sudo -v; then
        echo "Error: sudo authentication failed"
        return 1
    fi

    # Install certbot if not already installed
    if ! command -v certbot &>/dev/null; then
        echo "Installing certbot..."
        sudo apt update
        sudo apt install -y certbot python3-certbot-nginx
    fi

    # Build domain arguments for certbot
    local domain_args=""
    for domain in "${domains[@]}"; do
        domain_args="$domain_args -d $domain"
    done

    echo ""
    echo "Requesting SSL certificate for:"
    printf "  Domains: %s\n" "${domains[*]}"
    echo "  Email: $email"
    echo ""

    # Run certbot command
    echo "Running certbot..."
    sudo certbot --nginx --agree-tos --no-eff-email --email "$email" $domain_args

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "SSL certificate(s) installed successfully!"
        echo "You can test your SSL configuration at: https://www.ssllabs.com/ssltest/"
    else
        echo ""
        echo "Failed to install SSL certificate(s)"
        return 1
    fi
}
