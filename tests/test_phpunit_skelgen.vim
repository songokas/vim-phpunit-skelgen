let s:tc = unittest#testcase#new("PhpUnitSkel test")
" expose the local object only (we could expose the whole script scope
" using vim-unittest examples, but this is more elegant)
let s:tc.object = deepcopy(phpunit_skelgen#context(), 1)
let s:tc.object.testDir = '/tmp'
"create dirs
"call mkdir('/tmp/skelgen/tests', 'p')

function! s:tc.test_object()
    call self.assert_equal(g:phpunit_skelgen_params, self.object.params)
endfunction

function! s:tc.test_getClassSuccess()
    call self.assert_equal('testnamespace\group\A', self.object.getClass('tests/fixtures/lib/testnamespace/group/a.php'))
    call self.assert_equal('B', self.object.getClass('tests/fixtures/lib/b.php'))
endfunction

function! s:tc.test_getClassFailure()
    call self.assert_throw(self.object.getClass('tests/fixtures/nonexistingfile.php'))
endfunction

function! s:tc.test_validCwdSuccess()
endfunction

function! s:tc.test_generateTest()
    let content = self.object.generateTest('tests/fixtures/lib/b.php')
    call self.assert_equal(0, filereadable('/tmp/lib/BTest.php'), content)
endfunction

function! s:tc.test_generateTestWithNamespace()
    let content = self.object.generateTest('tests/fixtures/lib/testnamespace/group/a.php')
    call self.assert_equal(0, filereadable('/tmp/lib/testnamespace/group/ATest.php'), content)
endfunction

function! s:tc.test_generateTestFailure()
    let content = self.object.generateTest('tests/fixtures/lib/syntaxerror.php')
    call self.assert_not(filereadable('/tmp/lib/syntaxerrorTest.php'), content)
endfunction

