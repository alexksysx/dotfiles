# some more ls aliases
alias ll='ls -l'
alias la='ls -alh'
alias l='ls -CF'
alias lh='ls -larth'

#Alias section
#Enables cd .. with just ..
alias ..='cd ..'
#CMUS alias
alias cmus='tmux attach-session -t cmus || tmux new-session -A -D -s cmus "$(which cmus)"'
#Sudo edit
alias sudoedit='sudo -e'

## GIT
alias gs='git status'
alias ga='git add'
# alias gc='git commit'
gc() {
  git commit -m "$1"
}

## Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'


# yt-dlp aliases — download with thumbnail

alias youtube.audio='yt-dlp -f "bestaudio/best" -x --embed-thumbnail --add-metadata'
alias youtube.720p='yt-dlp -f "bestvideo[height<=720]+bestaudio/best[height<=720]" --merge-output-format mp4 --embed-thumbnail --add-metadata'
alias youtube.1080p='yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" --merge-output-format mp4 --embed-thumbnail --add-metadata'

#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.xz) tar xvf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Archive file or files
archive() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: archive <archive_name> <file1> [file2 ...]"
        return 1
    fi

    archive_name="$1"
    shift  # Удаляем первый аргумент (имя архива)

    case $archive_name in
        *.zip) 
            zip "$archive_name" "$@" 
            ;;
        *.tar.gz)
            tar cvzf "$archive_name" "$@" 
            ;;
        *.tar.xz)
            tar cvfJ "$archive_name" "$@" 
            ;;
        *) 
            echo "Unsupported archive format. Use .zip, .tar.gz, or .tar.xz."
            return 1
            ;;
    esac
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# mkdir and cd
mkcd () {
  \mkdir -p "$1"
  cd "$1"
}

# create tmp dir and cd
tempe () {
  cd "$(mktemp -d)"
  chmod -R 0700 .
  if [[ $# -eq 1 ]]; then
    \mkdir -p "$1"
    cd "$1"
    chmod -R 0700 .
  fi
}
