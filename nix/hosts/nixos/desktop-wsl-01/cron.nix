{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*0 */1 * * * fish -c 'backup_projects'"
    ];
  };
}
