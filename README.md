# Local Backup Automation (Ansible)

This project installs a local `rsync` backup script and schedules cron jobs to back up one or more directories.

## What it does

- Ensures `rsync` is installed.
- Installs `scripts/backup.sh` to `~/.local/bin/backup.sh`.
- Creates `~/log` for backup logs.
- Creates one cron entry per source directory.
- Runs backups daily at `04:00` by default.

## Files

- `backup.yaml`: main Ansible playbook.
- `scripts/backup.sh`: `rsync` wrapper script.

## Requirements

- Ansible installed on the local machine.
- Permission to install packages (`rsync`) if missing.
- Access to the backup target path.

## Usage

Run with defaults:

```bash
ansible-playbook backup.yaml
```

Override backup sources/target at runtime:

```bash
ansible-playbook backup.yaml \
  -e 'backup_dirs=["/home/marc/repos","/home/marc/Documents"]' \
  -e 'backup_target_root=/mnt/nfs-truenas/marc-bkup'
```

## Key variables

Defined in `backup.yaml` under `vars`:

- `script_dir`: destination directory for the backup script.
- `backup_script_path`: full path to installed backup script.
- `log_dir`: directory used for logs.
- `backup_log`: log file path used by cron jobs.
- `backup_target_root`: root destination for backups.
- `backup_hour` / `backup_minute`: cron schedule.
- `backup_dirs`: list of source directories to back up.

Each source in `backup_dirs` is synced into:

`<backup_target_root>/<basename_of_source_dir>`

Example: `/home/marc/repos` -> `/mnt/nfs-truenas/marc-bkup/repos`

## Log output

Cron appends output to:

`~/log/backup.log`
