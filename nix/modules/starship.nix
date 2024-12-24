{ pkgs, config, ... }:
{
  programs.starship.enable = true;
  programs.starship.settings = {
    username = {
      style_user = "blue bold";
      style_root = "red bold";
      format = "[$user]($style) ";
      disabled = false;
      show_always = true;
    };
    aws.disabled = true;
    gcloud.disabled = true;
    kubernetes.disabled = false;
    git_branch.style = "242";
    directory.style = "blue";
    directory.truncate_to_repo = false;
    directory.truncation_length = 8;
    python.disabled = false;
    ruby.disabled = true;
    hostname.ssh_only = false;
    hostname.style = "bold green";
  };
}
