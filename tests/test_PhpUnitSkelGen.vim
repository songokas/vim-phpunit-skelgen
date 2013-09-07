let s:tc = unittest#testcase#new("PhpUnitSkel test", phpunit_skelgen#__context__())

function! s:tc.test_PhpUnitSkel_getNamespaceSuccess()
		  call self.assert_equal(s:PhpUnitSkel.getNamespace('tests/fixtures/a.php'), 'testnamespace\\group')
		  "call self.assert_equal(self.get('s:PhpUnitSkel.getNamespace', 'tests/fixtures/b.php'), '')
endfunction

"function! s:tc.test_PhpUnitSkel_getNamespaceFailure()
"          call self.assert(self.get('s:PhpUnitSkel.getNamespace', ['tests/fixtures/nonexistantfile.php']))
"endfunction
