#!/bin/bash
set -eu

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

now() {
  # shellcheck disable=SC2005
  echo "$(date '+%Y-%m-%d %H:%M:%S')"
}

apps=(git composer npm npx node php)

for p in "${apps[@]}"; do
  if ! [ -x "$(command -v "${p}")" ]; then
      echo -e "${RED} ${p} seems to be not installed. Install it and then run the script again."
      exit 1
  fi
done

read -rp "Enter project name: " project
project="${project// /-}"

echo -e "${NC}$(now) ${GREEN}[notice] Starting install"

echo -e "${NC}$(now) ${GREEN}[notice] Installing Laravel"

cd ..

# Create a laravel project
composer create-project laravel/laravel "${project}"

cd "${project}"

echo -e "$(now) ${GREEN}[notice] Installing node_modules"
npm install
clear

# TailwindCSS
read -rp "Do you want to use TailwindCSS y/n: " use_tailwind
if [ "$use_tailwind" = 'y' ] || [ "$use_tailwind" = 'Y' ] || [ "$use_tailwind" = '' ]; then
  tailwind=true
else
  tailwind=false
fi

# Install TailwindCSS
if [ $tailwind ]; then
  tailwind_config="tailwind.config.js"

  echo -e "${NC}$(now) ${GREEN}[notice] Installing TailwindCSS"

  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p

  cp -f "../src/$tailwind_config" "$tailwind_config"
  cp -f "../src/css/app.css" "resources/css/app.css"
fi

clear

# ReactJS
read -rp "Do you want to use ReactJS y/n: " use_react
if [ "$use_react" = 'y' ] || [ "$use_react" = 'Y' ] || [ "$use_react" = '' ]; then
  react=true
else
  react=false
fi

# Install ReactJS
if [ $react ]; then
  vite_config="vite.config.js"

  echo -e "${NC}$(now) ${GREEN}[notice] Installing ReactJS"

  npm install -D laravel-vite-plugin
  npm install @babel/preset-react @vitejs/plugin-react react react-dom

  # Modifying Laravel for using ReactJS
  rm -rf "./resources/js"
  cp -rf "../src/js" "./resources"

  rm -f "./resources/views/welcome.blade.php"
  cp -f "../src/app.blade.php" "./resources/views/"

  cp -f "../src/web.php" "./routes/web.php"
  cp -f "../src/$vite_config" "$vite_config"
fi

clear

# Sail
read -rp "Do you want to use Sail y/n: " use_sail
if [ "$use_sail" = 'y' ] || [ "$use_sail" = 'Y' ] || [ "$use_sail" = '' ]; then
  sail=true
else
  sail=false
fi

if [ $sail ]; then
    php artisan sail:install
fi

clear

echo -e "${NC}$(now) ${GREEN}[notice] Installation completed"
exit 0
