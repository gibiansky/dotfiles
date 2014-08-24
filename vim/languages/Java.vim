if !exists("g:java_editing_init_done")
    let g:java_editing_init_done = 1

    " Java vim config "
    map <C-\> <ESC>:pop<CR>

    " Reimplement the vjde completion func to use noignorecase and then set it
    " back to smartcase. This is a bug in vjde. "
    func! VjdeCompletionFun0(findstart,base)
        set noignorecase
        if a:findstart
            let output=VjdeCompletionFun(getline('.'),a:base,col('.'),a:findstart)
            set smartcase
            return output
        endif
        let lval = VjdeCompletionFun(strpart(getline('.'),0,col('.')),a:base,col('.'),a:findstart)
        if type(lval) ==3 " List
            let output=lval
            set smartcase
            return output
        endif
        if strlen(s:retstr)<2
            let output=[]
            set smartcase
            return output
        else
            let output=split(s:retstr,"\n")
            set smartcase
            return output
        endif
    endf
    
    " Vim JDE "
    let g:vjde_lib_path=g:home."/.android/platforms/android-11/android.jar"

    fun! AddClassPath(classpath)
        let g:vjde_lib_path=g:vjde_lib_path . ":" . a:classpath
    endfun


    " For android, using ant "
    fun! AntMake()
        if system("which adb") == g:home . "/.android/platform-tools/adb\n"
            set makeprg=ant\ -emacs\ install
        else
            set makeprg=ant\ build
        endif
        make!
        let g:java_current_error_first=1
    endfun

    fun! AndroidRun()
        echo system("adb shell 'am start -n com.swerveanddestroy/.SwerveAndDestroy'")
    endfun

    " For maven "
    fun! MvnMake()
        set makeprg=mvn\ test
        set errorformat=
                    \%-G[%\\(WARNING]%\\)%\\@!%.%#,
                    \%A%[%^[]%\\@=%f:[%l\\,%v]\ %m,
                    \%W[WARNING]\ %f:[%l\\,%v]\ %m,
                    \%-Z\ %#,
                    \%-Clocation\ %#:%.%#,
                    \%C%[%^:]%#%m,
                    \%-G%.%#
        make!
        let g:java_current_error_first=1
    endfun

    " Error skipping "
    fun! NextError()
        if !exists("g:java_current_error_first")
            echo "Run make before correcting errors"
            return
        endif

        if g:java_current_error_first == 1
            let g:java_current_error_first=0
            cc
        else
            try
                cnext
                if match(bufname("%"), "main_rules.xml") >= 0
                    cprevious
                    echo ""
                    echo "No more errors"
                endif
            catch
                echo "No more errors"
            endtry
        endif
    endfun
    
    fun! PrevError()
        if !exists("g:java_current_error_first")
            echo "Run make before correcting errors"
            return
        endif

        try
            cprevious
            if match(bufname("%"), "main_rules.xml") >= 0
                cnext
                echo "No previous errors"
            endif
        catch
            echo "No previous errors"
        endtry
    endfun

    map <F5> :call AntMake()<CR>
    map <S-F5> :call MvnMake()<CR>
    map <C-F5> :call AndroidRun()<CR>
    imap <F5> <ESC>:call AntMake()<CR>
    imap <S-F5> <ESC>:call MvnMake()<CR>
    imap <C-F5> <ESC>:call AndroidRun()<CR>

    map <F6> :call NextError()<CR>
    map <S-F6> :call PrevError()<CR>
    imap <F6> <ESC><F6>
    imap <S-F6> <ESC><S-F6>

    "exec("source " . g:home . "/.vim/current-projects.vim")

    " Logcat 
    map <F7> :exec("!adb logcat '" . g:android_logcat_filter ."'")<CR>
    map <S-F7> :exec("!adb logcat '" . g:android_logcat_filter_shift . "'")<CR>
endif

" Allow delimitMate to add padding for braces "
let b:delimitMate_expand_cr=1
