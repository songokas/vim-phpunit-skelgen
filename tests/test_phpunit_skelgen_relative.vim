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
        execute '!ln -s' shellescape(s:ROOT_DIR . '/tests/fixtures/tests') 'tests'
    endif
endfunction

"function! s:tc.test_generateTesRelativeWorkingDirectory()
"    let content = self.object.generateTest('lib/testnamespace/group/a.php')
"    call self.assert(1, filereadable('tests/lib/testnamespace/group/ATest.php'), content)
"    let content = self.object.generateTest('lib/b.php')
"    call self.assert(1, filereadable('tests/lib/BTest.php'), content)
"endfunction

function! s:tc.test_generateClassRelativeWorkingDirectory()
    let content = self.object.generateClass('tests/games/BowlingGameTest.php')
    call self.assert(1, filereadable('games/BowlingGame.php'), content)
    let content = self.object.generateClass('tests/BowlingGameTest.php')
    call self.assert(1, filereadable('BowlingGame.php'), content)
endfunction
