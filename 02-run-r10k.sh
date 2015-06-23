#!/usr/bin/env bash

mkdir -p public-code-staging
r10k deploy environment -p -v
