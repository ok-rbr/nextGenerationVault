" [[ Setting options ]]
" Zeilennummern aktivieren
set number

" Relative Zeilennummern aktivieren (optional)
set relativenumber

" Mausmodus aktivieren
set mouse=a

" Modus-Anzeige deaktivieren (schon in der Statuszeile sichtbar)
set noshowmode

" System-Clipboard fÃ¼r Yank, Put und Delete verwenden
set clipboard=unnamedplus

" Conceal-Level setzen
set conceallevel=1

" Break-Indent aktivieren
set breakindent

" EinrÃ¼ckung basierend auf der vorherigen Zeile aktivieren
set autoindent
set smartindent
set cindent

" Undo-Historie speichern
set undofile

" Suchoptionen
set ignorecase
set smartcase

" Sign column immer anzeigen
set signcolumn=yes

" Update-Zeit verringern
set updatetime=250

" Timeout-Zeit fÃ¼r Mappings verkÃ¼rzen
set timeoutlen=300

" Standard-Splitrichtung setzen
set splitright
set splitbelow

" Vorschau bei Ersetzungen im geteilten Fenster anzeigen
set inccommand=split

" Cursor-Zeile anzeigen
set cursorline

" Minimalen Abstand zum oberen und unteren Bildschirmrand halten
set scrolloff=10

" Relative Zeilennummern aktivieren
set relativenumber

" [[ Keymaps ]]

" Hervorhebung bei Suche aufheben mit <Esc> in normalem Modus
nnoremap <Esc> :nohlsearch<CR>

" Diagnoseliste Ã¶ffnen (mapping zu <leader>q)
nnoremap <leader>q :lopen<CR>

" Terminalmodus verlassen mit <Esc><Esc> (funktioniert nur in Neovim)
tnoremap <Esc><Esc> <C-\><C-n>

" Pfeiltasten deaktivieren in normalem Modus
nnoremap <left> :echo "Use h to move!!"<CR>
nnoremap <right> :echo "Use l to move!!"<CR>
nnoremap <up> :echo "Use k to move!!"<CR>
nnoremap <down> :echo "Use j to move!!"<CR>

" Einfaches Navigieren in Splits mit CTRL+<hjkl>
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k

" [[ Autocommands ]]

" Highlight beim Kopieren
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank()  " Lua-Funktion wird in Vim nicht unterstÃ¼tzt
augroup END

" Auto-Formatierung fÃ¼r .cs-Dateien beim Speichern (funktioniert nur mit Vim-Plugins)
autocmd BufWritePre *.cs execute 'silent !dotnet format'  " Verwende ein externes Tool wie dotnet format fÃ¼r .NET-Formatierung

" PrÃ¼fe, ob Prettier geladen ist und bei bestimmten Dateitypen ausfÃ¼hren
augroup PrettierOnSave
  autocmd!
  autocmd BufWritePre *.json,*.js,*.ts,*.css,*.scss,*.md PrettierAsync
augroup END

" Faltmethode fÃ¼r Treesitter (nicht nativ in Vim, benÃ¶tigt Plugin)
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99

" PowerShell als Standard-Shell unter Windows
if has("win32")
  set shell=powershell
  set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
  set shellquote=
  set shellxquote=
elseif has("unix")
  set shell=pwsh
  set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
endif
