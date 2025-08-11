#!/bin/bash

# Constants
DANTE_PKG="dante-server"
PAM_PWD_PKG="libpam-pwdfile"
WHOIS_PKG="whois"
PAM_D_SOCKD="/etc/pam.d/sockd"
DANTE_CONF="/etc/danted.conf"
DANTE_PASSWD="/etc/dante.passwd"
DEFAULT_PORT=1080

# Function to check if the script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Use 'sudo' to run it."
        exit 1
    fi
}

# Install dante-server and additional packages
install_dante() {
    echo "Updating package list..."
    apt-get update

    echo "Installing dante-server..."
    apt-get install -y $DANTE_PKG

    echo "Installing additional packages..."
    apt-get install -y $PAM_PWD_PKG $WHOIS_PKG

    configure_danted_conf
    echo "Creating first user"
    add_user
    systemctl enable danted
    systemctl start danted
}

configure_danted_conf() {
    # Get available network interfaces
    interfaces=$(ip link show | awk -F': ' '/^[0-9]+: [a-zA-Z0-9._-]+:/ {print $2}')
    interface_list=($interfaces)

    # Prompt user to select an interface
    echo "Available network interfaces:"
    for i in "${!interface_list[@]}"; do
        echo "$((i+1)). ${interface_list[$i]}"
    done

    read -p "Select the internal interface [1-${#interface_list[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#interface_list[@]}" ]; then
        internal_interface="${interface_list[$choice-1]}"
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi

    # Prompt user to enter the port (default is 1080)
    read -p "Enter the port number for dante server (default: $DEFAULT_PORT): " port
    port=${port:-$DEFAULT_PORT}

    # Create a backup of the original danted.conf
    backup_dante_conf

    # Write the new configuration to danted.conf
    cat << EOF | tee $DANTE_CONF > /dev/null
logoutput: /var/log/socks.log
errorlog: /var/log/socks_error.log
internal: $internal_interface port = $port
external: $internal_interface
socksmethod: pam.username
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody
client pass {
    from: 0/0 to: 0/0
    log: connect disconnect error ioop
}
pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error ioop
}
EOF

    echo "Configured danted.conf with internal interface: $internal_interface and port: $port"
}

remove_dante() {
    echo "Stopping service"
    systemctl disable danted
    systemctl stop danted

    echo "Removing dante-server..."
    apt-get remove -y $DANTE_PKG
}

backup_dante_conf() {
    if [ -f "$DANTE_CONF" ]; then
        timestamp=$(date +%Y%m%d%H%M%S)
        cp $DANTE_CONF "$DANTE_CONF-$timestamp"
        echo "Backup created: $DANTE_CONF-$timestamp"
    else
        echo "dante configuration file not found. No backup created."
    fi
}

# Restore dante configuration from the most recent backup
restore_dante_conf() {
    # Find the most recent backup file
    backup_file=$(ls -t ${DANTE_CONF}-* 2>/dev/null | head -n 1)
    
    if [ -z "$backup_file" ]; then
        echo "No backup found to restore. Please create a backup first."
        return 1
    fi

    echo "Restoring configuration from backup: $backup_file"
    cp "$backup_file" "$DANTE_CONF"
    echo "Restored: $DANTE_CONF"
}

# Add user to dante
add_user() {
    read -p "Enter new username: " username

    if [ -z "$username" ]; then
        echo "Username cannot be empty. User not added."
        return 1
    fi

    # Securely read the password
    read -sp "Enter password for $username: " password
    echo
    read -sp "Confirm password for $username: " confirm_password
    echo

    if [ "$password" != "$confirm_password" ]; then
        echo "Passwords do not match. User not added."
        return 1
    fi

    hashed_password=$(mkpasswd --method=md5 $password)

    if grep -q "^$username:" $DANTE_PASSWD; then
        echo "User $username already exists. Updating password..."
        sed -i "s/^$username:.*/$username:$hashed_password/" $DANTE_PASSWD
    else
        echo "Adding new user: $username"
        echo "$username:$hashed_password" | tee -a $DANTE_PASSWD > /dev/null
    fi
}

# Remove user from dante
remove_user() {
    if [ ! -f "$DANTE_PASSWD" ]; then
        echo "No users found. User file does not exist."
        return 1
    fi

    # Get list of users
    mapfile -t users < <(awk -F: '{print $1}' $DANTE_PASSWD)

    if [ ${#users[@]} -eq 0 ]; then
        echo "No users found."
        return 1
    fi

    # Prompt user to select a user to remove
    echo "Available users to remove:"
    for i in "${!users[@]}"; do
        echo "$((i+1)). ${users[$i]}"
    done

    read -p "Select the user to remove [1-${#users[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#users[@]}" ]; then
        user_to_remove="${users[$choice-1]}"
        echo "Removing user: $user_to_remove"
        sed -i "/^$user_to_remove:/d" $DANTE_PASSWD
    else
        echo "Invalid selection. Exiting."
    fi
}

# List users
list_users() {
    if [ ! -f "$DANTE_PASSWD" ]; then
        echo "No users found. User file does not exist."
        return 1
    fi

    # Get list of users
    mapfile -t users < <(awk -F: '{print $1}' $DANTE_PASSWD)

    if [ ${#users[@]} -eq 0 ]; then
        echo "No users found."
    else
        echo "List of users:"
        for user in "${users[@]}"; do
            echo "$user"
        done
    fi
}

# Configure PAM for dante
configure_pam() {
    if ! grep -q "pam_pwdfile.so pwdfile $DANTE_PASSWD" $PAM_D_SOCKD; then
        echo "Configuring PAM for dante..."
        echo "" >> $PAM_D_SOCKD
        echo "auth required pam_pwdfile.so pwdfile $DANTE_PASSWD" >> $PAM_D_SOCKD
        echo "account required pam_permit.so" >> $PAM_D_SOCKD
    else
        echo "PAM already configured for dante."
    fi
}

# Show menu
show_menu() {
    echo "Choose an option:"
    echo "1. Install dante-server"
    echo "2. Remove dante-server"
    echo "3. Add user"
    echo "4. Remove user"
    echo "5. List users"
    echo "6. Backup configuration"
    echo "7. Restore configuration"
    echo "8. Exit"
}

# Main loop
check_root  # Check if the script is run as root

while true; do
    show_menu
    read -p "Enter your choice [1-8]: " choice

    case "$choice" in
        1)
            install_dante
            ;;
        2)
            remove_dante
            ;;
        3)
            add_user
            ;;
        4)
            remove_user
            ;;
        5)
            list_users
            ;;
        6)
            backup_dante_conf
            ;;
        7)
            restore_dante_conf
            ;;
        8)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done
