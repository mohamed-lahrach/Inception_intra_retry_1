# User Documentation - Inception Project

## Overview

This document explains how to use the Inception web infrastructure as an end user or system administrator. The infrastructure provides a complete WordPress website with secure HTTPS access, backed by a MariaDB database.

---

## Table of Contents

1. [Services Overview](#services-overview)
2. [Getting Started](#getting-started)
3. [Starting and Stopping the Project](#starting-and-stopping-the-project)
4. [Accessing the Services](#accessing-the-services)
5. [Managing Credentials](#managing-credentials)
6. [Checking Service Health](#checking-service-health)
7. [Common Tasks](#common-tasks)
8. [Troubleshooting](#troubleshooting)

---

## Services Overview

The Inception project provides the following services:

### 1. **Web Server (NGINX)**
- **Purpose**: Serves the WordPress website over secure HTTPS
- **Technology**: NGINX web server with TLS/SSL encryption
- **Port**: 443 (HTTPS only)
- **Access**: https://mlahrach.42.fr

### 2. **Content Management System (WordPress)**
- **Purpose**: Website content creation and management
- **Technology**: WordPress 6.x with PHP-FPM 7.4
- **Features**:
  - Full WordPress CMS functionality
  - Admin dashboard for site management
  - Two user accounts: Administrator and Author
  - Plugin and theme support
  
### 3. **Database (MariaDB)**
- **Purpose**: Stores all website data (posts, users, settings)
- **Technology**: MariaDB (MySQL-compatible database)
- **Access**: Internal only (not exposed to host)
- **Persistence**: Data saved in `$HOME/data/mariadb` (automatically configured per user)

---

## Getting Started

### Prerequisites

Before using the infrastructure, ensure:
- You have access to the host machine where Docker is installed
- You have sudo privileges (for starting services)
- The domain `mlahrach.42.fr` points to the server

### Initial Setup

1. **Configure the domain** (one-time setup):
   ```bash
   sudo sh -c 'echo "127.0.0.1 mlahrach.42.fr" >> /etc/hosts'
   ```

2. **Verify the domain resolution**:
   ```bash
   ping mlahrach.42.fr
   ```
   You should see responses from `127.0.0.1`.

---

## Starting and Stopping the Project

### Starting the Infrastructure

To start all services:

```bash
make
```

**What happens:**
- Creates data directories if they don't exist (`$HOME/data/mariadb` and `$HOME/data/wordpress`)
- Sets proper permissions on data folders
- Builds Docker images (first time or after changes)
- Starts all three containers (NGINX, WordPress, MariaDB)
- Services start automatically on system reboot

**Expected output:**
```
mkdir -p $HOME/data/mariadb
mkdir -p $HOME/data/wordpress
...
[+] Running 3/3
 ✔ Container mariadb    Started
 ✔ Container wordpress  Started
 ✔ Container nginx      Started
```

**Time to start:**
- First time: 2-5 minutes (downloads images, installs WordPress)
- Subsequent starts: 10-30 seconds

### Stopping the Infrastructure

To stop all services without removing data:

```bash
make down
```

**What happens:**
- Stops all running containers
- Containers can be restarted without data loss
- Data in volumes remains intact

### Complete Cleanup

⚠️ **WARNING: This deletes all data including posts, pages, and uploads!**

To remove everything including stored data:

```bash
make fclean
```

**What gets deleted:**
- All containers
- All Docker images
- All data in `$HOME/data/mariadb`
- All data in `$HOME/data/wordpress`

Use this only when you want to start completely fresh.

---

## Accessing the Services

### Accessing the Website

**URL**: https://mlahrach.42.fr

1. Open your web browser
2. Navigate to `https://mlahrach.42.fr`
3. **Accept the security warning** (the SSL certificate is self-signed)
   - Chrome: Click "Advanced" → "Proceed to mlahrach.42.fr (unsafe)"
   - Firefox: Click "Advanced" → "Accept the Risk and Continue"
   - Safari: Click "Show Details" → "visit this website"

4. You should see the WordPress homepage

### Accessing the WordPress Admin Panel

**URL**: https://mlahrach.42.fr/wp-admin

**Administrator Login:**
- **Username**: `mlahrach`
- **Password**: Found in `secrets/mariadb_wordpress_password.txt` (default: `passwordtyt`)

**What you can do:**
- Create and edit posts and pages
- Manage website appearance (themes)
- Install and configure plugins
- Manage users
- Configure site settings
- View website statistics

### Accessing as Author User

**Author Login:**
- **Username**: `mohamed`
- **Password**: Found in `secrets/wordpress_author_password.txt` (default: `user123456`)

**Author capabilities:**
- Create and edit own posts
- Upload media files
- Publish articles
- Cannot modify themes or plugins
- Cannot manage other users

---

## Managing Credentials

### Password Storage

All passwords are stored securely in the `secrets/` directory:

```
secrets/
├── mariadb_root_password.txt        → Database root password
├── mariadb_wordpress_password.txt   → WordPress admin & DB user password
└── wordpress_author_password.txt    → WordPress author user password
```

### Viewing Passwords

**From host machine:**
```bash
cat secrets/mariadb_wordpress_password.txt
```

### Changing Passwords

⚠️ **WARNING: Changing passwords requires rebuilding the infrastructure!**

1. **Stop the services:**
   ```bash
   make down
   ```

2. **Edit the password file:**
   ```bash
   nano secrets/mariadb_wordpress_password.txt
   ```

3. **Remove existing data:**
   ```bash
   make fclean
   ```

4. **Start fresh with new password:**
   ```bash
   make
   ```

### Password Security Best Practices

✅ **Do:**
- Use strong passwords (mix of letters, numbers, symbols)
- Keep password files secure (proper file permissions)
- Regularly backup password files securely
- Change default passwords in production

❌ **Don't:**
- Commit password files to version control
- Share passwords in plain text
- Use the same password for multiple services
- Write passwords in documentation or comments

---

## Checking Service Health

### Quick Health Check

**Verify all containers are running:**
```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE       STATUS         PORTS                  NAMES
abc123def456   nginx       Up 2 minutes   0.0.0.0:443->443/tcp   nginx
def456ghi789   wordpress   Up 2 minutes   9000/tcp               wordpress
ghi789jkl012   mariadb     Up 2 minutes   3306/tcp               mariadb
```

All three containers should show `Up` status.

### Detailed Service Checks

#### 1. Check NGINX (Web Server)

**View NGINX logs:**
```bash
docker logs nginx
```

**Healthy output should show:**
```
Successfully generated SSL certificate
nginx: [notice] start worker processes
```

**Test HTTPS connection:**
```bash
curl -k https://mlahrach.42.fr
```
Should return HTML content.

#### 2. Check WordPress (Application)

**View WordPress logs:**
```bash
docker logs wordpress
```

**Healthy output should show:**
```
WordPress already installed, skipping install steps.
starting php-fpm
[NOTICE] ready to handle connections
```

**Access WordPress status:**
Navigate to `https://mlahrach.42.fr/wp-admin` - should show login page.

#### 3. Check MariaDB (Database)

**View MariaDB logs:**
```bash
docker logs mariadb
```

**Healthy output should show:**
```
[Note] mysqld: ready for connections
```

**Test database connection:**
```bash
docker exec -it mariadb mysql -uroot -p$(cat secrets/mariadb_root_password.txt) -e "SHOW DATABASES;"
```

Should list databases including `wordpress`.

### Monitoring Service Resource Usage

**View real-time resource usage:**
```bash
docker stats
```

Shows CPU, memory, network I/O for each container.

**Expected resource usage:**
- **NGINX**: <1% CPU, ~5-10 MB RAM
- **WordPress**: 1-5% CPU, ~50-100 MB RAM
- **MariaDB**: 1-5% CPU, ~100-200 MB RAM

---

## Common Tasks

### Creating a New Blog Post

1. Log in to WordPress admin: https://mlahrach.42.fr/wp-admin
2. Click **Posts** → **Add New**
3. Enter your post title and content
4. Click **Publish**
5. View your post on the homepage

### Uploading Media Files

1. In WordPress admin, click **Media** → **Add New**
2. Drag and drop files or click **Select Files**
3. Uploaded files appear in the Media Library
4. Insert media into posts using the **Add Media** button

### Installing a WordPress Theme

1. Go to **Appearance** → **Themes**
2. Click **Add New**
3. Browse or search for themes
4. Click **Install** → **Activate**
5. Customize under **Appearance** → **Customize**

### Installing a WordPress Plugin

1. Go to **Plugins** → **Add New**
2. Search for desired plugin
3. Click **Install Now** → **Activate**
4. Configure plugin settings if needed

### Backing Up Your Website

**Manual backup:**
```bash
# Backup WordPress files
cp -r $HOME/data/wordpress $HOME/backup/wordpress_$(date +%Y%m%d)

# Backup database
cp -r $HOME/data/mariadb $HOME/backup/mariadb_$(date +%Y%m%d)
```

**Restoring from backup:**
```bash
make down
rm -rf $HOME/data/wordpress $HOME/data/mariadb
cp -r $HOME/backup/wordpress_20231215 $HOME/data/wordpress
cp -r $HOME/backup/mariadb_20231215 $HOME/data/mariadb
make
```

### Viewing Website Analytics

WordPress doesn't include analytics by default. To add:

1. Install **Jetpack** or **Google Site Kit** plugin
2. Follow plugin setup wizard
3. Connect to your analytics account
4. View stats in WordPress dashboard

---

## Troubleshooting

### Website Not Loading

**Problem**: Cannot access https://mlahrach.42.fr

**Solutions**:

1. **Check services are running:**
   ```bash
   docker ps
   ```
   All 3 containers should be `Up`.

2. **Check domain resolution:**
   ```bash
   ping mlahrach.42.fr
   ```
   Should resolve to `127.0.0.1`.

3. **Verify /etc/hosts entry:**
   ```bash
   cat /etc/hosts | grep mlahrach
   ```
   Should show: `127.0.0.1 mlahrach.42.fr`

4. **Check NGINX logs:**
   ```bash
   docker logs nginx
   ```

5. **Restart services:**
   ```bash
   make down
   make
   ```

### Cannot Login to WordPress

**Problem**: Login page shows error or credentials rejected

**Solutions**:

1. **Verify password:**
   ```bash
   cat secrets/mariadb_wordpress_password.txt
   ```

2. **Check WordPress is ready:**
   ```bash
   docker logs wordpress | tail -20
   ```
   Should show "ready to handle connections".

3. **Reset WordPress if needed:**
   ```bash
   make fclean
   make
   ```
   ⚠️ This deletes all content!

### Database Connection Error

**Problem**: WordPress shows "Error establishing database connection"

**Solutions**:

1. **Check MariaDB is running:**
   ```bash
   docker logs mariadb
   ```

2. **Verify database exists:**
   ```bash
   docker exec mariadb mysql -uroot -p$(cat secrets/mariadb_root_password.txt) -e "SHOW DATABASES;"
   ```

3. **Check WordPress can reach database:**
   ```bash
   docker exec wordpress ping -c 3 mariadb
   ```

4. **Restart MariaDB:**
   ```bash
   docker restart mariadb
   docker restart wordpress
   ```

### SSL Certificate Warning

**Problem**: Browser shows "Your connection is not private"

**This is expected behavior!** The SSL certificate is self-signed.

**Solution**: Click "Advanced" and proceed to the website. This is safe for development/testing.

For production, you would need a certificate from a Certificate Authority (Let's Encrypt, etc.).

### Slow Performance

**Problem**: Website loads slowly or times out

**Solutions**:

1. **Check resource usage:**
   ```bash
   docker stats
   ```

2. **Check disk space:**
   ```bash
   df -h $HOME/data
   ```

3. **Restart services:**
   ```bash
   make down
   make
   ```

4. **Check logs for errors:**
   ```bash
   docker logs nginx
   docker logs wordpress
   docker logs mariadb
   ```

### Lost Data After Restart

**Problem**: Posts/pages disappeared after restarting

**Possible causes:**
- Volumes not properly mounted
- Data directory permissions incorrect
- Used `make fclean` instead of `make down`

**Prevention:**
- Always use `make down` to stop (not `make fclean`)
- Regularly backup data directories
- Don't manually delete files in `$HOME/data/`

---

## Getting Help

### Log Files

View logs for debugging:

```bash
# All services
docker compose -f srcs/docker-compose.yml logs

# Specific service
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow logs in real-time
docker logs -f wordpress
```

### Container Shell Access

Access container for advanced troubleshooting:

```bash
# WordPress container
docker exec -it wordpress /bin/bash

# MariaDB container
docker exec -it mariadb /bin/bash

# NGINX container
docker exec -it nginx /bin/bash
```

### Support Resources

- **42 Intranet**: Check Inception project forum
- **Docker Documentation**: https://docs.docker.com/
- **WordPress Support**: https://wordpress.org/support/
- **Peers**: Ask fellow 42 students

---

## Best Practices

### Regular Maintenance

- **Backup weekly**: Copy data directories
- **Check logs monthly**: Look for warnings/errors
- **Update passwords**: Change defaults in production
- **Monitor disk space**: Ensure adequate free space
- **Test backups**: Verify backups can be restored

### Security Reminders

- Don't use default passwords in production
- Keep password files secure
- Don't share admin credentials
- Use strong passwords (12+ characters)
- Log out after admin tasks

### Data Safety

- Use `make down` to stop (preserves data)
- Never use `make fclean` unless starting fresh
- Backup before major changes
- Keep backups in multiple locations

---

## Quick Reference

### Essential Commands

| Task                     | Command                              |
|--------------------------|--------------------------------------|
| Start services           | `make`                               |
| Stop services            | `make down`                          |
| View running containers  | `docker ps`                          |
| View logs                | `docker logs [container_name]`       |
| Access website           | https://mlahrach.42.fr               |
| Access admin panel       | https://mlahrach.42.fr/wp-admin      |
| Backup data              | `cp -r $HOME/data $HOME/backup/`     |

### Default Credentials

| Service          | Username | Password Location                            |
|------------------|----------|----------------------------------------------|
| WordPress Admin  | mlahrach | `secrets/mariadb_wordpress_password.txt`     |
| WordPress Author | mohamed  | `secrets/wordpress_author_password.txt`      |
| Database Root    | root     | `secrets/mariadb_root_password.txt`          |

---

**Last Updated**: December 2025  
**For Developer Documentation**: See DEV_DOC.md
