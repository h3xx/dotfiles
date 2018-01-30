" quick temporary file creation
append
$temp_file = tempnam(sys_get_temp_dir(), 'MYFILE');

// Cleanup when exiting
register_shutdown_function(function ($temp_file) {
	@unlink($temp_file);
}, $temp_file);
.
