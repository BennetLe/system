#!/usr/bin/env bash

nix build /home/bennet/system#homeConfigurations.bennet.activationPackage
/home/bennet/system/result/activate
