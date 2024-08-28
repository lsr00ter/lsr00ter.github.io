#!/bin/bash
filename=$(date +%Y-%m-%d-new-post.md)
if [ $# -gt 0 ]; then
  filename=$(date +%Y-%m-%d-)
  title=$(echo "$@")
  filename+=$(echo "$@" | sed -e 's/ /-/g').md
else
  filename=$(date +%Y-%m-%d-new-post.md)
fi
cat >$filename <<EOF
---
layout: post
title: $title
description: A description
date: '$(date '+%Y-%m-%d %H:%M:%S')'
categories: ["category"]
tags: ["tag"]   # TAG names should always be lowercase
---
EOF
