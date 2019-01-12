echo "Installing node modules..."

echo "Setting up required folders..."

echo "Removing unnecessary stuff..."
del .gitignore
del README.md

echo "Building project..."
cake build

echo "Done! now run your project with 'node app' or 'cake run' and build something awesome!"