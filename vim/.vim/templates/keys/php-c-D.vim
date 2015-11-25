" insert a deprecation warning for a constuctor

exe "norm opublic function __construct() {\<CR>trigger_error('Deprecated class: '.__CLASS__);\<CR>}\<Esc>"
