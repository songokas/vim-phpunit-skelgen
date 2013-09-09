let s:tc = unittest#testcase#new("PhpUnitSkel test absolute paths")

let s:ROOT_DIR = expand('<sfile>:h:h')

function! s:tc.setup()
    " expose the local object only (we could expose the whole script scope
    " using vim-unittest examples, but this is more elegant)
    let self.object = deepcopy(phpunit_skelgen#context(), 1)
    let self.object.testDir = '/tmp'
endfunction

function! s:tc.test_object()
    call self.assert_equal(g:phpunit_skelgen_params, self.object.params)
endfunction

function! s:tc.test_getClassSuccess()
    call self.assert_equal('testnamespace\group\A', self.object.getClass(s:ROOT_DIR . '/tests/fixtures/lib/testnamespace/group/a.php'))
    call self.assert_equal('B', self.object.getClass(s:ROOT_DIR . '/tests/fixtures/lib/b.php'))
endfunction

function! s:tc.test_getClassFailure()
"    call self.assert_throw('/PHP/', self.object.getClass(s:ROOT_DIR . '/tests/fixtures/nonexistingfile.php'))
    try
        call self.object.getClass(s:ROOT_DIR . '/tests/fixtures/nonexistingfile.php')
    catch /PHP/
        call self.assert(1)
        return
    endtry
    call self.assert(0, 'Failed to throw exception')
endfunction

function! s:tc.test_generateTest()
    let content = self.object.generateTest(s:ROOT_DIR . '/tests/fixtures/lib/b.php')
    call self.assert_equal(0, filereadable('/tmp/lib/BTest.php'), content)
endfunction

function! s:tc.test_generateTestWithNamespace()
    let content = self.object.generateTest(s:ROOT_DIR . '/tests/fixtures/lib/testnamespace/group/a.php')
    call self.assert_equal(0, filereadable('/tmp/lib/testnamespace/group/ATest.php'), content)
endfunction;

function! s:tc.test_generateTestFailure()
    try
        call self.object.generateTest(s:ROOT_DIR . '/tests/fixtures/lib/syntaxerror.php')
    catch /PHP/
        call self.assert(1)
        return
    endtry
    call self.assert(0, 'Php exception parse error')
endfunction

