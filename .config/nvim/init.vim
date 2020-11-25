if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
    Plug 'junegunn/goyo.vim'
    Plug 'sonph/onehalf', {'rtp': 'vim/'}
    Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'
"    Plug 'valloric/youcompleteme'
call plug#end()

    syntax on
    filetype plugin on

"Set color settings for onehalf
    set t_Co=256
    set cursorline
    colorscheme onehalfdark 
    let g:airline_theme='onehalfdark'
"
    set laststatus=2  "Status bar (1 or 2)

"Additional info in status bar
    set statusline=%<%f%h%m%r%=format=%{&fileformat}\ file=%{&fileencoding}\ enc=%{&encoding}\ %b\ 0x%B\ %l,%c%V\ %P   

"Список кодировок файлов для автоопределения
    set fileencodings=utf-8,cp1251,koi8-r,cp866

	set et		"Автозамена по умолчанию
	set ai		"Автоотступ для новых строк
	set cin		"Отступы в стиле Си
"Поиск и подсветка результата
	set showmatch
	set hlsearch
	set incsearch
	set ignorecase
"Табы и пробелы
	set tabstop=4
	set shiftwidth=4
	set smarttab

	set wildmode=longest,list,full
    set wildmenu

    set path+=**    "Путь для поиска файлов
	set nocompatible

	set number relativenumber "Относительные строки
"Открытие сплита справа или снизу
	set splitbelow splitright
"Навигация по сплитам
	map <C-h> <C-w>h
	map <C-j> <C-w>j
	map <C-k> <C-w>k
	map <C-l> <C-w>l

"Изменение размеров сплитов
    noremap <silent> <C-Left> :vertical resize +3<CR>
    noremap <silent> <C-Right> :vertical resize -3<CR>
    noremap <silent> <C-Up> :resize +3<CR>
    noremap <silent> <C-Down> :resize -3<CR>

"Turn on Goyo
    map <C-G> :Goyo<CR>
"Open NERDTree
    map <C-n> :NERDTreeToggle<CR>

"Goyo on start settings
    function! s:goyo_enter()
        set number relativenumber
        let b:quitting = 0
        let b:quitting_bang = 0
        autocmd QuitPre <buffer> let b:quitting = 1
        cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
    endfunction
    
    function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
        if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
         if b:quitting_bang
             qa!
         else
             qa
         endif
        endif
    endfunction


autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()
