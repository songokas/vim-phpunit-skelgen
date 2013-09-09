let s:tc = unittest#testcase#new("PhpUnitSkel test relative paths")

let s:ROOT_DIR = expand('<sfile>:h:h')

function! s:tc.setup()
    let self.object = deepcopy(phpunit_skelgen#context(), 1)
    let self.object.testDir = 'tests'
    "project working directory
    let projectDir = '/tmp/phpunit_skelgen_project'
    if !isdirectory(projectDir)
        call mkdir(projectDir)
    endif
    execute 'cd' projectDir
    if !isdirectory('lib')
        execute '!ln -s' shellescape(s:ROOT_DIR . '/tests/fixtures/lib') 'lib'
    endif
endfunction

function! s:tc.test_generateTesRelativeWorkingDirectory()
    let content = self.object.generateTest('lib/testnamespace/group/a.php')
    call self.assert(1, filereadable('tests/lib/testnamespace/group/ATest.php'), content)
    let content = self.object.generateTest('lib/b.php')
    call self.assert(1, filereadable('tests/lib/BTest.php'), content)
endfunction
