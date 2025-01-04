{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 */1 * * *  root  /opt/backup_projects.sh >> /var/log/backup_projects.log 2>&1"
      "*/5 * * * *  root  date >> /tmp/cron.log"
    ];
  };
}
