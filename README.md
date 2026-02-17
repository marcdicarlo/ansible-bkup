# Local Backup Automation (Ansible)

This project installs a local tar/xz backup script and schedules cron jobs to back up one or more directories.

## What it does

- Installs `scripts/backup.sh` to `~/.local/bin/backup.sh`.
- Creates `~/log` for backup logs.
- Creates one cron entry per source directory.
- Runs backups daily at `04:00` by default.
- Creates compressed timestamped archives (`.tar.xz`) per source.
- Keeps only the configured number of newest backups per source.

## Files

- `backup.yaml`: main Ansible playbook.
- `scripts/backup.sh`: tar/xz archive script.

## Requirements

- Ansible installed on the local machine.
- `tar` and `xz` installed on the local machine.
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
- `backups_to_keep`: number of newest archives retained per source.
- `backup_hour` / `backup_minute`: cron schedule.
- `backup_dirs`: list of source directories to back up.

Each source in `backup_dirs` is archived into:

`<backup_target_root>/<basename_of_source_dir>`

Example archive path:

`/mnt/nfs-truenas/marc-bkup/repos/repos_20260216_040000.tar.xz`

## Log output

Cron appends output to:

`~/log/backup.log`

## Restore example

Restore from an archive with `tar`:

```bash
tar -xJf /mnt/nfs-truenas/marc-bkup/repos/repos_20260216_040000.tar.xz -C /home/marc
```
