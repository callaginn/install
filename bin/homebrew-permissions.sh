# Might as well ask for password up-front, right?
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

folders=(
	~/Library/Caches/Homebrew
	~/Library/Logs/Homebrew
	/opt/homebrew-cask
)

echo ""
echo "Correcting permissions on the following folders:"
for folder in "${folders[@]}"; do
	test -d $folder && echo "$folder"
	test -d $folder && sudo chown -R $(whoami) $folder
done

ls -d1 $(brew --prefix)/*
sudo chown -R $(whoami) $(brew --prefix)/*
