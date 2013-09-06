" Author:  TsonJGoku <bizabrazija at gmail.com>
" License: The MIT License
" URL:     https://github.com/TsonJgoku/vim-phpunit-skelgen.git
" Version: 0.1
"
" default mapping:
" nnoremap <Leader>gs :PhpGenSkel<Enter>
"
" binary file to run
if !exists('g:phpunit_skelgen')
    let g:phpunit_skelgen = 'phpunit-skelgen'
endif

" root of unit tests
if !exists('g:phpunit_testroot')
    let g:phpunit_testroot = 'tests'
endif

" params to append
if !exists('g:phpunit_skelgen_params')
    let g:phpunit_skelgen_params = ''
endif

"CLASS: PhpUnitSkel
"============================================================
let s:PhpUnitSkel = {}
let s:PhpUnitSkel.bin = g:phpunit_skelgen
let s:PhpUnitSkel.testDir = g:phpunit_testroot
let s:PhpUnitSkel.params = g:phpunit_skelgen_params

" FUNCTION: PhpUnitSkel.run()   {{{1
" run the executable
function! s:PhpUnitSkel.run(args)
    let command = self.bin . ' ' . self.params . ' ' . a:args
    echo command
    return system(command)
endfunction

" FUNCTION: PhpUnitSkel.generateTest()   {{{1
" generate test class for current file
function! s:PhpUnitSkel.generateTest()
    let namespace = self.getNamespace()
    if !empty(namespace)
        namespace += '\\'
    endif
    let filePath = expand('%')
    let className = namespace . expand('%:t:r')
    let testClassName = className . 'Test'
    let testFileTempPath = self.testDir . '/' . filePath
    let testFilePath = substitute(testFileTempPath, className, testClassName, '')
    let testFileDir = fnamemodify(testFilePath, ':p:h')
    if !isdirectory(testFileDir)
        call mkdir(testFileDir, 'p')
    endif
    let args = ' --test -- ' . shellescape(className) . ' ' . shellescape(filePath) . ' ' . shellescape(testClassName) . ' ' . shellescape(testFilePath)
    let output = self.run(args)
    call self.output(output, testFilePath)
endfunction

" FUNCTION: PhpUnitSkel.generateClass()   {{{1
" generate class from current test file
function! s:PhpUnitSkel.generateClass()
    let namespace = self.getNamespace()
    if !empty(namespace)
        namespace += '\\'
    endif
    let testFilePath = expand('%')
    let testClassName = namespace . expand('%:t:r')
    let className = matchstr(testClassName,  '\\?\zs.\+\zeTest')
    if empty(className)
        throw 'Not a test file ' . testClassName . '. Test file ends with Test.php'
    let filePath = matchstr(testFilePath, self.testDir . '/\zs.\+')
    let fileDir = fnamemodify(filePath, ':p:h')
    let namespace = self.getNamespace()
    if !empty(namespace)
        let namespaceString = shellescape(namespace) . ' '
    else
        let namespaceString = ''
    endif
    if !isdirectory(fileDir)
        call mkdir(fileDir, 'p')
    endif

    let args = ' --class -- ' . namespaceString . shellescape(testClassName). ' ' . shellescape(testFilePath). ' ' . shellescape(className) . ' ' . shellescape(filePath)
    let output = self.run(args)
    call self.output(output, filePath)
endfunction

" FUNCTION: PhpUnitSkel.getNamespace() {{{1
" returns file namespace
function! s:PhpUnitSkel.getNamespace()
    let lineNr = search('^namespace.\+;$', 'n')
    if !(lineNr > 0)
        return ""
    endif
    let line = getline(lineNr)
    let namespace = matchstr(line, 'namespace\s\+\zs.\+\ze;')
    return namespace
endfunction

" FUNCTION: PhpUnitSkel.output() {{{1
" output the command contents and open a buffer
function! s:PhpUnitSkel.output(content, filePath)
    :echo a:content
    execute 'sp ' . a:filePath
endfunction

" SECTION: Commands {{{1
"===========================================
"
function! PhpGenSkel()
    let is_test = expand('%:t') =~ 'Test\.'
    try
        if is_test
            call s:PhpUnitSkel.generateClass()
        else
            call s:PhpUnitSkel.generateTest()
        endif
    catch
       echo 'Error: ' . v:exception
    endtry
endfunction


command! PhpGenSkel call PhpGenSkel()

if !exists('g:phpunit_skelgen_key_map') || !g:phpunit_skelgen_key_map
    autocmd FileType php nnoremap <Leader>gs :PhpGenSkel<Enter>
endif
