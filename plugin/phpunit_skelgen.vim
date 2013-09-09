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

" root of unit tests (relative to your working directory)
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
let s:PhpUnitSkel.classParser = fnamemodify(expand('<sfile>:h:h') . '/bin/classParser.php', '%')

" FUNCTION: PhpUnitSkel.run()   {{{1
" run the executable
function! s:PhpUnitSkel.run(args)
    let command = self.bin . ' ' . self.params . ' ' . a:args
    let content = system(command)
    let returnValue = v:shell_error
    if returnValue > 0
        throw content
    endif
    return content
endfunction

" FUNCTION: PhpUnitSkel.generateTest()   {{{1
" generate test class for current file
function! s:PhpUnitSkel.generateTest(filePath)
    let className = self.getClass(a:filePath)
    let testClassName = className . 'Test'
    let identifiers = split(testClassName, '\\')
    let testClassNoNamespace = get(identifiers, -1)
    let testFileTempPath = fnamemodify(self.testDir . '/' . a:filePath, '%')
    let testFileDir = fnamemodify(testFileTempPath, ':p:h')
    let testFilePath = fnamemodify(testFileDir . '/' . testClassNoNamespace . '.php', '%')
    if !isdirectory(testFileDir)
        call mkdir(testFileDir, 'p')
    endif
    let args = ' --test -- ' . shellescape(className) . ' ' . shellescape(a:filePath) . ' ' . shellescape(testClassName) . ' ' . shellescape(testFilePath)
    let output = self.run(args)
    call PhpUnitSkelGenOutput(output, testFilePath)
    return output
endfunction

" FUNCTION: PhpUnitSkel.generateClass()   {{{1
" generate class from current test file
function! s:PhpUnitSkel.generateClass(testFilePath)
    let testClassName = self.getClass(a:testFilePath)
    let className = matchstr(testClassName,  '\zs[^\s]\+\zeTest$')
    if empty(className)
        throw 'Not a test file ' . testClassName . '. Test file ends with Test.php'
    let filePath = matchstr(a:testFilePath, self.testDir . '\zs.\+')
    let fileDir = fnamemodify(filePath, ':p:h')
    if !isdirectory(fileDir)
        call mkdir(fileDir, 'p')
    endif
    let args = ' --class -- ' . shellescape(testClassName). ' ' . shellescape(a:testFilePath). ' ' . shellescape(className) . ' ' . shellescape(filePath)
    let output = self.run(args)
    call PhpUnitSkelGenOutput(output, filePath)
    return output
endfunction

" FUNCTION: PhpUnitSkel.getClass() {{{1
" returns file class
function! s:PhpUnitSkel.getClass(filePath)
    let className = system('php ' . shellescape(self.classParser) . ' ' . shellescape(a:filePath))
    let returnValue = v:shell_error
    if returnValue > 0
        throw className
    endif
    return className
endfunction

"===========================================

" FUNCTION: PhpUnitSkelGenOutput() {{{1
" output the command contents and open a buffer
" override it if you need something else
function! PhpUnitSkelGenOutput(content, filePath)
    echo a:content
    if filereadable(a:filePath)
        execute 'vsp' a:filePath
    endif
endfunction

" SECTION: Commands {{{1
"===========================================


" FUNCTION: PhpGenSkel() {{{1
" generate skeleton for current file
" if current file is a class a test file will be created
" if current file is a test class a class file will be created
function! PhpGenSkel(filePath)
    try
        let realFilePath = !empty(a:filePath) ? a:filePath : expand('%')
        let is_test = fnamemodify(realFilePath, '%:t') =~ 'Test\.'
        if is_test
            call s:PhpUnitSkel.generateClass(realFilePath)
        else
            call s:PhpUnitSkel.generateTest(realFilePath)
        endif
    catch
       echo 'Error: ' . v:exception
    endtry
endfunction


command! -nargs=? -complete=file PhpGenSkel call PhpGenSkel(<q-args>)

if !exists('g:phpunit_skelgen_key_map') || !g:phpunit_skelgen_key_map
    autocmd FileType php nnoremap <Leader>gs :PhpGenSkel<Enter>
endif

"===========================================================
" UNITTEST:
"function! phpunit_skelgen#__context__()
"  return { 'sid': s:SID, 'scope': s: }
"endfunction

"function! s:get_SID()
"  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
"endfunction
"let s:SID = s:get_SID()
"delfunction s:get_SID

function! phpunit_skelgen#context()
    return s:PhpUnitSkel
endfunction
