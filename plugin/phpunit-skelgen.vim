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
function! s:PhpUnitSkel.generateTest(filePath)
    let namespace = self.getNamespace(a:filePath)
    if !empty(namespace)
        namespace += '\\'
    endif
    let className = namespace . fnamemodify(a:filePath, '%:t:r')
    let testClassName = className . 'Test'
    let testFileTempPath = self.testDir . '/' . a:filePath
    let testFilePath = substitute(testFileTempPath, className, testClassName, '')
    let testFileDir = fnamemodify(testFilePath, ':p:h')
    if !isdirectory(testFileDir)
        call mkdir(testFileDir, 'p')
    endif
    let args = ' --test -- ' . shellescape(className) . ' ' . shellescape(a:filePath) . ' ' . shellescape(testClassName) . ' ' . shellescape(testFilePath)
    let output = self.run(args)
    call PhpUnitSkelGenOutput(output, testFilePath)
endfunction

" FUNCTION: PhpUnitSkel.generateClass()   {{{1
" generate class from current test file
function! s:PhpUnitSkel.generateClass(testFilePath)
    let namespace = self.getNamespace(a:testFilePath)
    if !empty(namespace)
        namespace += '\\'
    endif
    let testClassName = namespace . fnamemodify(a:testFilePath, '%:t:r')
    let className = matchstr(testClassName,  '\\?\zs.\+\zeTest')
    if empty(className)
        throw 'Not a test file ' . testClassName . '. Test file ends with Test.php'
    let filePath = matchstr(a:testFilePath, self.testDir . '/\zs.\+')
    let fileDir = fnamemodify(filePath, ':p:h')
    if !isdirectory(fileDir)
        call mkdir(fileDir, 'p')
    endif

    let args = ' --class -- ' . shellescape(testClassName). ' ' . shellescape(a:testFilePath). ' ' . shellescape(className) . ' ' . shellescape(filePath)
    let output = self.run(args)
    call PhpUnitSkelGenOutput(output, filePath)
endfunction

" FUNCTION: PhpUnitSkel.getNamespace() {{{1
" returns file namespace
function! s:PhpUnitSkel.getNamespace(filePath)
    for line in readfile(a:filePath, '', 100)
        if line =~ '^namespace.\+;$' | break | endif
	endfor
    let namespace = matchstr(line, 'namespace\s\+\zs.\+\ze;')
    return namespace
endfunction

"===========================================

" FUNCTION: PhpUnitSkelGenOutput() {{{1
" output the command contents and open a buffer
" override it if you need something else
function! PhpUnitSkelGenOutput(content, filePath)
    echo a:content
    execute 'sp ' . a:filePath
endfunction

" SECTION: Commands {{{1
"===========================================


" FUNCTION: PhpGenSkel() {{{1
" generate skeleton for current file
" if current file is a class a test file will be created
" if current file is a test class a class file will be created
function! PhpGenSkel(filePath)
    let realFilePath = !empty(a:filePath) ? a:filePath : expand('%')
    let is_test = fnamemodify(realFilePath, '%:t') =~ 'Test\.'
    try
        if is_test
            call s:PhpUnitSkel.generateClass(realFilePath)
        else
            call s:PhpUnitSkel.generateTest(realFilePath)
        endif
    catch
       echo 'Error: ' . v:exception
    endtry
endfunction


command! -nargs=? -complete=file PhpGenSkel call PhpGenSkel(<args>)

if !exists('g:phpunit_skelgen_key_map') || !g:phpunit_skelgen_key_map
    autocmd FileType php nnoremap <Leader>gs :PhpGenSkel<Enter>
endif
