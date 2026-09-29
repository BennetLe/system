let
  bennet = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlQkqu/cPdgeUG3BUPqFh7yOw+tRhcCQaPwYLGXtaQy root@nixos";
  bennet-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBubInOxUyHqJW8uxOVBLOML+MhSTudhJC61Tjnt4v9k";
  framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhKJD5LXtdC2C/jkjNrs749Ko/hr0tJA4sZRrfX268P bennet@nixos";
in {
  "homepage.env.age".publicKeys = [bennet bennet-user];
}
