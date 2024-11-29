#!/usr/bin/env bash

nix build .#homeConfigurations.bennet.activationPackage
./result/activate
