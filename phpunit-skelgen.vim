" Author:  TsonJGoku <bizabrazija at gmail.com>
" License: The MIT License
" URL:     https://github.com/TsonJgoku/vim-phpunit-skelgen.git
" Version: 0.1
"
" default mapping:
" nnoremap <Leader>gs :PhpGenSkel<Enter>
"
" binary file to run
"
if !exists('g:phpunit_skelgen')
  let g:phpunit_skelgen = 'phpunit-skelgen'
endif

"
" root of unit tests
"
if !exists('g:phpunit_testroot')
  let g:phpunit_testroot = 'tests'
endif

"
" params to append
"
if !exists('g:phpunit_skelgen_params')
  let g:phpunit_skelgen_params = ''
endif

function! s:PhpSkelGenRun(args)
    :echo g:phpunit_skelgen . ' ' . g:phpunit_skelgen_params . ' ' . a:args
    return system(g:phpunit_skelgen . ' ' . g:phpunit_skelgen_params . ' ' . a:args)
endfunction


function! PhpGenSkel()
    let is_test = expand('%:t') =~ "Test\."
    if is_test
        call PhpGenClassSkel()
    else
        call PhpGenTestSkel()
    endif
endfunction

function! PhpGenTestSkel()
    let filePath = expand('%')
    let className = expand('%:t:r')
    let testClassName = className . 'Test'
    let testFileTempPath = g:phpunit_testroot . '/' . filePath "substitute(filePath, getcwd(), getcwd() . g:phpunit_testroot . '/', '')
    let testFilePath = substitute(testFileTempPath, className, testClassName, '')
    let args = ' --test -- ' . className . ' ' . filePath . ' ' . testClassName . ' ' . testFilePath
    let output = s:PhpSkelGenRun(args)
    g:PhpSkelGenOutput(output)
endfunction

function! g:PhpSkelGenOutput(output)
    :echo output
    execute 'sp ' . testFilePath
endfunction


command! PhpGenSkel call PhpGenSkel()

if !exists('g:phpunit_skelgen_key_map') || !g:phpunit_skelgen_key_map
    nnoremap <Leader>gs :PhpGenSkel<Enter>
endif
