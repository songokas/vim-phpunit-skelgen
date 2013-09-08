<?php

/*error_reporting(0);*/
/*ini_set('display_errors', 0);*/

function getClassName($file) {
    $fp = @fopen($file, 'r');
    if (!$fp) {
        throw new InvalidArgumentException("File does not exist $file");
    }
    $class = $namespace = $buffer = '';
    $i = 0;
    while (!$class) {
        if (feof($fp)) break;

        $buffer .= fread($fp, 512);
        $tokens = token_get_all($buffer);

        if (strpos($buffer, '{') === false) continue;

        for (;$i<count($tokens);$i++) {
            if ($tokens[$i][0] === T_NAMESPACE) {
                for ($j=$i+1;$j<count($tokens); $j++) {
                    if ($tokens[$j][0] === T_STRING) {
                        $namespace .= $namespace ? '\\'.$tokens[$j][1] : $tokens[$j][1];
                    } else if ($tokens[$j] === '{' || $tokens[$j] === ';') {
                        break;
                    }
                }
            }

            if ($tokens[$i][0] === T_CLASS) {
                for ($j=$i+1;$j<count($tokens);$j++) {
                    if ($tokens[$j] === '{') {
                        $class = $tokens[$i+2][1];
                    }
                }
            }
        }
    }
    return $namespace ? $namespace . '\\' . $class : $class;
}
if (isset($argv[1])) {
    echo getClassName($argv[1]);
    exit(0);
}
exit(1);
