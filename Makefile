stow_dirs = $(wildcard */)
ignore_regex = "ignore"
.PHONY : stow
stow :
	stow --target $(HOME) --verbose --dotfiles --ignore=$(ignore_regex) $(stow_dirs) 
.PHONY : stow-verbose
# verbosity goes from 0 to 4
VERBOSITY=1
stow-verbose :
	stow --verbose $(VERBOSITY) --target $(HOME) --dotfiles --ignore=$(ignore_regex) --verbose $(stow_dirs)

.PHONY : dry-run
dry-run :
	stow --no --target $(HOME) --dotfiles --ignore=$(ignore_regex) --verbose $(stow_dirs)

.PHONY : restow
restow :
	stow --target $(HOME) --dotfiles --ignore=$(ignore_regex) --verbose --restow $(stow_dirs)

# Do this *before* moving to another directory.
.PHONY : delete
delete :
	stow --target $(HOME) --dotfiles --ignore=$(ignore_regex) --verbose --delete $(stow_dirs)
