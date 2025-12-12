#!/bin/bash
cd /home/rails/rails_work/task-collab-platform/frontend
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 22.12.0
npm run dev
