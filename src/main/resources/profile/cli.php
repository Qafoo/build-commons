<?php
function __ant_build_commons_profile($startTime)
{
    ob_end_clean();
    echo "Execution time (s),Memory usage (Mb)", PHP_EOL;
    printf(
        "%d,%.2f",
        (time() - $startTime),
        (memory_get_peak_usage() / 1024 / 1024),
        PHP_EOL
    );
}

register_shutdown_function('__ant_build_commons_profile', time());

ob_start();
