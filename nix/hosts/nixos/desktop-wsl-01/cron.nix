{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * * /bin/bash /opt/backup_projects.sh >> /var/log/backup_projects.log 2>&1"
      "*/5 * * * *      root    date >> /tmp/cron.log"
    ];
  };
}
