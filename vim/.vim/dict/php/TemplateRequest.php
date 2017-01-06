$_SESSION[$unique_form_name] = $token;
$_SESSION['create_time'] = time();
$_SESSION['last_page'] = $prefix . $page;
$_SESSION['origURL'] = "";
$_SESSION['origURL'] = $_SERVER['HTTP_REFERER'];
$_SESSION['origURL'] = substr($_SESSION['origURL'], 0, 249);
$_SESSION[self::SESSION_INITIATED] = true;
$_SESSION[self::SESSION_USER] =& $user;
$_SESSION[self::SESSION_USER]->last_name;
$accesses = $this->getPageAccess();
$accesses = array($accesses);
$authValue = $_REQUEST[AuthUtility::getAuthKey()];
$authorized = false;
$authorized = true;
$c=chr(ord('0')+$r-26);
$c=chr(ord('a')+$r);
$class = str_replace('\\', DIRECTORY_SEPARATOR, $class);
$className = get_class($this);
$config = HTMLPurifier_Config::createDefault();
$config->set($key, $value);
$config->set('Cache.SerializerPath', 'templates_c');
$config=[
$configFile=self::DEFAULT_CONFIG_FILE;
$csrf_key = $this->config->getConfig("cross_site_request_forgery_key", "CSRFKEY");
$csrf_token = "";
$csrf_token = $_POST[$csrf_key];
$csrf_token = $_SESSION[$csrf_key];
$csrf_token = $this->csrfguard_generate_token($csrf_key);
$database_dsn = self::getConfigParam('database_dsn');
$db = new PDO($dsn, $user, $password, [
$dbName = substr($database_dsn, $pos + 1);
$dir.='/';
$dir=substr($uri,-1)=='/' ? $uri : dirname($uri);
$directory .= "/";
$directory .= "data/";
$directory .= "email/";
$directory = self::getConfigParam("destination_dir");
$dsn=$config[self::DB_DSN_PARAM];
$editHTML = '';
$editHTML = '<div style="position:fixed;right:0;top:0;z-index:99999;padding:5px;font-family: \'Courier New\'">' .
$envImage = EnvironmentIdentifierUtil::getEnvironmentIdentifierImage($this->database, $this->smarty);
$eventExtraPath .
$eventExtraPath = '';
$eventExtraPath = PATH_SEPARATOR . "$path/" . SmartyHelper::getInstance()->get('event_code') . "/page" .
$extra_path = "";
$extra_path = self::getConfigParam("page_path");
$extra_path = str_replace('./eclib:./eclib/utility:./eclib/shell:./eclib/page:', '', $extra_path);
$extra_path = str_replace(array('$path', ':'), array($path, PATH_SEPARATOR), $extra_path);
$filename = '/var/log/' . self::getConfigParam('database_user') . '_template_request_log';
$fp = fopen($filename, 'a+');
$helper = SmartyHelper::getInstance();
$helper->set('db_user', self::getConfigParam(TemplateRequest::DB_USER_PARAM));
$helper->setCompileDir(static::COMPILE_DIR);
$helper->setDatabase($this->database);
$helper->setSmarty($this->smarty);
$hostname=@$_SERVER['HTTP_HOST'];
$last_slash_pos = strrpos($url['path'], '/');
$location = SmartyHelper::getInstance()->get('event_code') . '/' . $location;
$location="$scheme://$hostname$dir$location";
$location_uri = parse_url($location);
$lock = "/tmp/$dbName.lock";
$logArray = array();
$logArray['COOKIE'] = $_COOKIE;
$logArray['GET'] = $_GET;
$logArray['POST'] = $_POST;
$logArray['REMOTE_ADDR'] = $_SERVER['REMOTE_ADDR'];
$logArray['REQUEST_URI'] = $_SERVER['REQUEST_URI'];
$logArray['SERVER_NAME'] = $_SERVER['SERVER_NAME'];
$logArray['USER_AGENT'] = $_SERVER['HTTP_USER_AGENT'];
$logArray['person_id'] = $_SESSION[self::SESSION_USER]->person_id;
$logArray['person_name'] = $_SESSION[self::SESSION_USER]->first_name . ' ' .
$logArray['timestamp'] = date('c');
$logText .= "\n";
$logText = print_r($logArray, true);
$loginValue = $_REQUEST[AuthUtility::getLoginKey()];
$overwrite = isset($params['overwrite']) ? $params['overwrite'] : false;
$page .= "#".$url['fragment'];
$page .= "?".$url['query'];
$page = $_SERVER['REQUEST_URI'];
$page = $url['path'];
$pageCode = basename($_SERVER['SCRIPT_NAME'], '.php');
$page_code = $request_value;
$page_code = isset($_REQUEST[$source]) ? $_REQUEST[$source] : "";
$params = array(
$params = session_get_cookie_params();
$password=isset($config[self::DB_PASSWORD_PARAM]) ? $config[self::DB_PASSWORD_PARAM] : null;
$personID = isset($this->user) ? $this->user->person_id : null;
$pos = strpos($database_dsn, '=');
$prefix .= "&" . AuthUtility::getLoginKey() . "=" . $loginValue;
$prefix .= "&";
$prefix .= AuthUtility::getAuthKey() . "=" . $authValue;
$prefix = "";
$prefix = $_REQUEST['event_id'] . '/';
$prefix = '';
$purifier = new HTMLPurifier($config);
$r=mt_rand(0,35);
$result = ($token === $token_value);
$saveDir = $this->getEmailSaveDirectory();
$scheme=@$_SERVER['HTTPS'] ? 'https' : 'http';
$section = $params['section'];
$section = null;
$sessionTimeout = null;
$sessionTimeout = self::getConfigParam(self::SESSION_TIMEOUT_PARAM);
$session_handler = new DatabaseSessionHandler;
$session_handler->setDatabase($this->database);
$smarty->config_load($params['file'], $section);
$smarty->config_overwrite = $overwrite;
$smarty->force_compile = false;
$smarty->force_compile = true;
$source = $this->config->getConfig('client.tracking_code_field', 'source');
$sql = "insert into page_click (person_id, page_code, click_time, ip_address, referrer, user_agent) values (:person_id, :page_code, :click_time, :ip_address, :referrer, :user_agent) ";
$sql = "select count(*) from page_visit where person_id = ? and visit_time >= now() - interval '$sessionTimeout minutes'";
$stmt = $this->database->prepare($sql);
$stmt->execute(array($this->user->person_id));
$stmt->setFetchMode(PDO::FETCH_NUM);
$tag = isset($_REQUEST['tag']) ? $_REQUEST['tag'] : null;
$template = $this->handleError($e->getMessage());
$template = $this->handleRequest($_REQUEST);
$template = self::getConfigParam(self::ERROR_TEMPLATE);
$templateDirs = $this->smarty->getTemplateDir();
$templateDirs = array($this->smarty->template_dir);
$this->analyticsInterface = new GoogleAnalyticsInterface($trackingCode, $_REQUEST, 'pageview');
$this->analyticsInterface->buildPostRequestFields();
$this->analyticsInterface->sendData();
$this->assign("csrf_key", $csrf_key);
$this->assign("csrf_token", $csrf_token);
$this->assign('config', $this->config);
$this->assign('envImage', $envImage);
$this->assign('helper', $helper);
$this->assign('is_edit_mode', false);
$this->assign('is_edit_mode', true);
$this->assign('statusMessage', $e->getMessage());
$this->checkForPause();
$this->config = ConfigUtil::getInstance();
$this->config->setDatabase($this->database);
$this->database = $this->openDatabase();
$this->database = null;
$this->dieString('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">' . PHP_EOL .
$this->dieString('Error: Unable to load smarty3/Smarty.class.php: File does not exist.');
$this->dieString(0);
$this->displayTemplate($template);
$this->header("Content-Type: text/html; charset=utf-8");
$this->header("Content-Type: text/xml; charset=utf-8");
$this->header("HTTP/1.0 401 Unauthorized");
$this->header("Location: $location");
$this->header("WWW-Authenticate: Basic realm=\"" .$realm. "\"");
$this->header('X-UA-Compatible: chrome=1');
$this->insertPageVisit();
$this->logPageView();
$this->logRequest();
$this->pageAccesses = $access;
$this->pageAccesses = array($access);
$this->pageVisitLogged = true;
$this->postCheck();
$this->redirect($_SERVER['REQUEST_URI']);
$this->redirect($loginPage . '?' . $prefix . 'page=' . urlencode($_SERVER['REQUEST_URI']));
$this->redirect($loginPage . '?' . $prefix . 'page=' . urlencode($uri));
$this->redirect($loginPage);
$this->redirect('https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
$this->saveURL();
$this->session->setWebUserID($this->user->webuser_id);
$this->session->setWebUserID($user->webuser_id);
$this->session_handler = $session_handler;
$this->setCSRFToken();
$this->setSessionCookieParams();
$this->setSessionHandler($session_handler);
$this->setSessionName();
$this->smarty = new Smarty();
$this->smarty->addTemplateDir('./autolib/templates/', 'autolib/templates');
$this->smarty->addTemplateDir('./eclib/js/', 'eclib/js');
$this->smarty->addTemplateDir('./eclib/templates/', 'eclib/templates');
$this->smarty->addTemplateDir('./emaxlib/js/', 'emaxlib/js');
$this->smarty->addTemplateDir('./emaxlib/templates/', 'emaxlib/templates');
$this->smarty->addTemplateDir('./eventlib/templates/', 'eventlib/templates');
$this->smarty->assign($name);
$this->smarty->assign($name, $value);
$this->smarty->clearAssign($name);
$this->smarty->clear_assign($name);
$this->smarty->display($template);
$this->smarty->force_compile = true;
$this->smarty->registerPlugin('function', 'read_config', array('TemplateRequest', 'smartyReadConfig'));
$this->smarty->register_function('read_config', array('TemplateRequest', 'smartyReadConfig'));
$this->smarty->setCompileDir('./' . $helper->get('event_code') . '/templates_c/');
$this->smarty->setTemplateDir($templateDirs);
$this->smarty->template_dir = $templateDirs;
$this->user = $_SESSION[self::SESSION_USER];
$this->validateUserAccess($this->user);
$token = $_SESSION[$unique_form_name];
$token.=$c;
$token=' ';
$token=hash("sha512",mt_rand(0,mt_getrandmax()));
$trackingCode = $this->config->getConfig('analytics.server_side_tracking_id', 'UA-45686709-2');
$uri = basename($_SERVER['REQUEST_URI']);
$uri=@$_SERVER['REQUEST_URI'];
$url = parse_url($page);
$url['path'] = substr($url['path'], $last_slash_pos+1);
$user = $_SESSION[self::SESSION_USER];
$user =& $_SESSION[self::SESSION_USER];
$user=isset($config[self::DB_USER_PARAM]) ? $config[self::DB_USER_PARAM] : null;
&&  $_REQUEST[self::AJAX_PARAM] == 'true')
'&nbsp;|&nbsp;<a target="_blank" href="template_edit.php?filename=' . $template . '">edit ' . basename($template) . '</a></div>';
'</body></html>');
'</head><body>' . PHP_EOL .
'<a target="_blank" href="class_edit.php?class_name=' . $className . '">edit ' . $className . '</a>' .
'<a target="_blank" href="page_edit.php?page_code=' . $pageCode . '">edit ' . $pageCode . '</a>&nbsp;|&nbsp;' .
'<h1>Authorization Required</h1>' . PHP_EOL .
'<html><head>' . PHP_EOL .
'<p>This server could not verify that you' . PHP_EOL .
'<title>401 Authorization Required</title>' . PHP_EOL .
'are authorized to access the document you' . PHP_EOL .
'browser doesn\'t understand how to supply' . PHP_EOL .
'click_time' => date("Y-m-d H:i:s"),
'credentials (e.g., bad password), or your' . PHP_EOL .
'ip_address' => $_SERVER['REMOTE_ADDR'],
'page_code' => $page_code,
'person_id' => $personID,
'referrer' => $_SESSION['origURL'],
'requested.  Either you supplied the wrong' . PHP_EOL .
'the credentials required.</p>' . PHP_EOL .
'user_agent' => $_SERVER['HTTP_USER_AGENT'],
);
*
*                  is found.
*          session was found
*      same name or false to add them to an array
*   Whether to wait for the lock to disappear.
*  DatabaseSessionHandler, FileSessionHandler
*  automatically call `session_write_close` when PHP exists.
*  that implements SessionHandlerInterface Possible classes include
* @deprecated - replace with `EnvUtil::getInstallType() === 'demo'`
* @deprecated - replace with `EnvUtil::getServerType() === 'dev'`
* @deprecated - replace with `EnvUtil::getServerType() === 'prod' && EnvUtil::getInstallType() === 'prod'`
* @param SessionHandlerInterface $session_handler An object of a class
* @param Webuser $user
* @param array $config the configuration parameters
* @param bool $register_shutdown Whether to register a shutdown handler to
* @param bool $wait
* @return PDO the PDO Database object
* @return Webuser : the user information from the session or null if no
* @return bool
* @return bool : true or false if there was an error
* @return bool True if/when the lock has been released.
* @throws Exception
* @throws Exception a PDOException if the database could not be opened.
* Assign a variable to the HTML template.
* Base class for handling an HTML page that use the Smarty template engine.
* CSRF code has been adapted from code found here:
* Clear a variable in the HTML template.
* Constructor to create a new TemplateRequest class.
* Create a Cross Site Request Forgery token and store in the session
* Create a new web session for a user
* Default getPageAccess method
* Delete the current user session.
* Determine if environment is production by checking if 'demo' is not part of the database user name
* Display a Smarty template page.
* Do database logging on page counts
* Function to handle database pausing
* Function to handle error message. This function must be defined by the
* Function to handle page request. This function must be defined by the
* Get the user information from the current web session.
* Go to another page location. This function will cause the script to
* If the subclass defines a method called "getPageAccess", this method
* Insert record into page_visit table, if enabled in config file, and if has
* Log GET, POST, COOKIE, etc., based on config parameters
* Open the database.
* Read an 'INI' configuration file into Smarty. The config parameters can
* Read in config params from config file into static array configParams
* Return the path to the email queueing directory
* Return the value for a parameter in the TemplateRequest.ini config file.
* Return the version of smarty to use for this page
* Return whether this is an AJAX request.
* Save the URL of the current page in the 'last_page' parameter of
* Set a page's accesses. Useful for setting in a wrapper file.
* Set the root path used to find PHP classes.
* Smarty template file to display. Sub-classes can use the "assign" member
* The sub-classes must also define the function "handleError" to handle any
* This base class opens the database and creates an instance of the Smarty
* Valid values are: TemplateRequest::SMARTY_2 or TemplateRequest::SMARTY_3, or simply 2 or 3
* Validate a user's access to a page based on the user's access rights.
* are passed to handleRequest in the function parameter. After the
* be accessed in Smarty with hash symbols around the variable name:
* e.g. #param_name#
* exceptions or error messages in the application. The error message is
* exit immediately.
* function to assign Smarty variable values.
* handleRequest function processes the request, it returns the name of the
* have any of them, this method will throw an Exception.
* https://owasp.org/index.php/PHP_CSRF_Guard
* not already been inserted
* param file: the file to read relative to the php/configs directory
* param location: the new location to go to
* param loginPage: the URL of the login page to display if no session
* param message: the error message
* param name: the parameter name to return
* param name: the template variable name
* param name: the template variable name to clear
* param overwrite: set to true to overwrite the parameter values with the
* param params: the page  parameters (from a form post or the query string)
* param path: the new include path to search in
* param section: only read in the parameters in the specified file section
* param template: the template page to display
* param user: the user information to store in the session
* param value: the template variable value
* passed as a parameter to the handleError function. After it processes
* returns: a path to a writable directory
* returns: the name of the Smarty template page to display
* returns: the parameter value or false if not found
* returns: true if an AJAX request, otherwise false
* returns: true if configuration file was successfully read
* sub-class.
* template engine. It calls the "handleRequest" function defined in sub-classes
* the error, it returns the name of a Smarty template page to display.
* the user has at least one of those accesses. If the user does not
* the user's session. If the page is reloaded, this URL will be displayed
* to handle the page. The parameters passed in the HTTP POST and query string
* will get a list of accesses from that method and check to see if
**/
*/
/* TODO : wait for PHP 5.5
/**
/** @var  ConfigUtil $config */
/** @var  PDO $database */
/** @var  Smarty $smarty */
/** @var  Webuser $user */
/** @var HTMLPurifier_Config $config */
/** @var Webuser $user */
// "session fixation" attack.
// Allows you to reload the database on-the-fly
// Analytics is set up before handleRequest is done, so you have a chance to modify the analytics data sent on a page-by-page basis!
// Call the "handleRequest" function in the sub-class to
// Catch and ignore if page visit insert fails
// Close database before going to new page
// Close session information (automatically done by session_handler)
// Close the database
// Configure email handler
// Destroy the session information
// Display the Smarty template page
// Google Analytics: Server Side Tracking
// If a user session is currently active, delete it.
// If user is not defined, destroy the current session
// Insert page visit record if enabled and not already inserted
// Look for a post field with the key value
// Make redirect url an absolute path
// Make sure user variable is defined
// Open the database
// Re-generate session ID to prevent
// Re-start the PHP session
// Remove the session cookie
// Return current user object if already set
// See http://www.php.net/session for more information.
// Set content type for AJAX request to XML
// Set default content-type for AJAX request to XML
// Set the session handler functions
// Store the user information in the session data
// [2014-02-25] - Added ability to only log based on certain fields.
// [2014-02-25] - Added source availability to track where they came from, ie CitrixEmailBlast or CitrixHomepage
// [2014-10-27] - Changed to allow for noncase sensitive tracking code
// handle the page request
// support namespaces
//..
//Hack, since you can't concatenate constants when declaring a class constant
//If no DB config is specified, use the default
//Supposedly addressed in PHP 5.6
//Use this instead of normal die/exit to allow unit tests to capture output
//Use this instead of normal echo to allow unit tests to capture output
//Use this instead of normal header() to allow unit tests to capture output
<?php
@session_destroy();
@session_destroy();  // Session may have already been created by session_start used for captcha handling
@session_regenerate_id();
@session_start();
@shell_exec("/usr/local/bin/sudo /usr/bin/touch $filename && /usr/local/bin/sudo /usr/sbin/chown www $filename");
CountLog::updateLog($this->database, $user->person_id, $className);
EventMailer::EmailConfig($saveDir);
Log::writeln("Error message " . $e->getMessage());
Log::writeln("TR Exception: " . print_r($e, true));
PATH_SEPARATOR . "$extra_path" .
PATH_SEPARATOR . "$path" .
PATH_SEPARATOR . "$path/" . SmartyHelper::getInstance()->get('event_code') . "/database" .
PATH_SEPARATOR . "$path/" . SmartyHelper::getInstance()->get('event_code') . "/utility";
PATH_SEPARATOR . "$path/database" .
PATH_SEPARATOR . "$path/eventlib" .
PATH_SEPARATOR . "$path/eventlib/database");
PATH_SEPARATOR . "$path/eventlib/utility" .
PATH_SEPARATOR . "$path/page" .
PATH_SEPARATOR . "$path/utility" .
PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
PageVisit::insertPageVisit($this->database, $personID, get_class($this), $tag, $page_code);
PageVisit::insertPageVisit($this->database, $personID, get_class($this), $tag, null);
SmartyHelper::getInstance()->set('root_path', $path);
]);
];
abstract class TemplateRequest
abstract protected function handleError($message);
abstract protected function handleRequest(&$params);
array_unshift($templateDirs, $helper->get('event_code') . '/templates/');
array_unshift($templateDirs, './' . $helper->get('event_code') . '/templates/');
break;
case 'pBarcode128':
case 'pBarcode39':
case 'pBubble':
case 'pCache':
case 'pData':
case 'pDraw':
case 'pImage':
case 'pIndicator':
case 'pPie':
case 'pRadar':
case 'pScatter':
case 'pSplit':
case 'pSpring':
case 'pStock':
case 'pSurface':
catch (Exception $e)
catch (Exception $e) {
clearstatcache();
const ACCESS_DENIED = 100;
const AJAX_PARAM = 'ajax';
const COMPILE_DIR = './templates_c';
const DB_DSN_PARAM = 'database_dsn';
const DB_PASSWORD_PARAM = 'database_password';
const DB_USER_PARAM = 'database_user';
const DEFAULT_CONFIG_FILE = TEMPLATE_REQUEST_DEFAULT_CONFIG_FILE;
const DEFAULT_CONFIG_PATH = TEMPLATE_REQUEST_DEFAULT_CONFIG_PATH;
const DEFAULT_SESSION_NAME = 'G2SESSID';
const ENABLE_CONFIG_PARAM = 'enable_config';
const ERROR_TEMPLATE = 'error_template';
const FORCE_COMPILE_PARAM = 'smarty_force_compile';
const FORCE_SSL = 'force_ssl';
const PAGE_VISIT_LOGGING = 'enable_page_visit_log';
const SESSION_INITIATED = 'initiated';
const SESSION_NAME_PARAM = 'php_session_name';
const SESSION_TIMEOUT_PARAM = 'session_timeout';
const SESSION_USER = 'user';
const SMARTY_2 = 2;
const SMARTY_3 = 3;
const SUPER_LOGIN = 'super_login';
define('PROJECT_PHP_DIR', __DIR__.'/../../');
define('TEMPLATE_REQUEST_DEFAULT_CONFIG_FILE', PROJECT_PHP_DIR.'/configs/TemplateRequest.ini');
define('TEMPLATE_REQUEST_DEFAULT_CONFIG_PATH', PROJECT_PHP_DIR.'/configs');
die($string);
die();
echo $editHTML;
echo $string;
else
elseif (!class_exists('Smarty', false))
elseif ($this->getSmartyVersion() === self::SMARTY_2)
elseif ($this->getSmartyVersion() === self::SMARTY_3)
elseif (($name = self::getConfigParam(self::SESSION_NAME_PARAM)))
elseif (isset(self::$configParams[$name]))
error_log($e);
fclose($fp);
finally {
for ($i=0;$i<128;++$i)
foreach ($_SESSION as $key => $value)
foreach ($accesses as $access)
foreach ($configSetArray as $key => $value)
foreach($_REQUEST as $key => $request_value) {
function csrfguard_generate_token($unique_form_name)
function csrfguard_validate_token($unique_form_name,$token_value)
function template_autoload($class)
fwrite($fp, $logText);
header($string);
header('Content-Type: text/plain');
if (! $authorized)
if (! $className)
if (! file_exists($filename))
if (! file_exists('pchart/cache'))
if (! isset($_SESSION[self::SESSION_USER]))
if (! isset($user->person_id))
if (!$extra_path)
if (!$overwrite)
if (!$this->pageVisitLogged) {
if (!empty($_SERVER['HTTP_REFERER'])) {
if (!empty($_SESSION['origURL']) && strlen($_SESSION['origURL']) > 250) {
if (!empty($database_dsn)) {
if (!empty($params['file']) && is_file($smarty->config_dir . "/" . $params['file']))
if (!empty($params['section']))
if (!empty($sessionTimeout))
if (!empty($url['fragment']))
if (!empty($url['path']))
if (!empty($url['query']))
if (!empty(self::$sessionNameSuffix))
if (!is_array($page_code)) {
if (!is_dir($directory))
if (!is_writable($directory) || mkdir($directory, 0775) === false)
if (!isset($_COOKIE['edit_mode']) || (isset($_COOKIE['edit_mode']) && $_COOKIE['edit_mode'] == 'ON'))
if (!isset($_SERVER['PHP_AUTH_PW']) || $_SERVER['PHP_AUTH_PW'] != $passwd) {
if (!isset($_SESSION[self::SESSION_INITIATED]))
if (!isset($config[self::DB_DSN_PARAM]))
if (!isset($this->session_handler) && session_id() != "")
if (!isset($this->session_handler))
if ($directory[strlen($directory)-1] != '/')
if ($e->getCode() == self::ACCESS_DENIED && self::getConfigParam(self::ERROR_TEMPLATE))
if ($envImage)
if ($errstr == "Smarty error: the \$compile_dir 'templates_c' does not exist, or is not a directory.")
if ($helper->get('project_has_directory'))
if ($key != self::SESSION_INITIATED && $key != self::SESSION_USER)
if ($last_slash_pos !== false)
if ($pos !== false) {
if ($r<26)
if ($row = $stmt->fetch())
if ($row[0] == 0)
if ($stmt && $stmt->execute($params)) {
if ($this->config->getConfig('disable_session_timeout', false))
if ($this->getForceSSL() && !isset($_SERVER['HTTPS']))
if ($this->getSmartyVersion() == self::SMARTY_2)
if ($this->getSmartyVersion() === self::SMARTY_2)
if ($this->getSmartyVersion() === self::SMARTY_3)
if ($this->isAjaxRequest())
if ($this->save_url && !$this->isAjaxRequest())
if ($this->user->hasAccess('edit_content'))
if ($this->validateCSRFToken() === false)
if ($user->hasAccess($access))
if ($user->hasAccess('development') && $this->config->getPersonConfig($user->person_id, 'dev_edit_page', false))
if ($wait) {
if (SmartyHelper::getInstance()->get('project_has_directory') && stripos($location, 'http') !== 0)
if (SmartyHelper::getInstance()->get('project_has_directory'))
if (SmartyHelper::getInstance()->get('resource_path') !== null && SmartyHelper::getInstance()->get('project_has_directory') === null && !empty($_REQUEST['event_id']))
if (empty($_POST))
if (empty($_SESSION[$csrf_key]))
if (empty($_SESSION['origURL'])) {
if (empty($directory))
if (empty($location_uri['scheme']) && substr($location,0,1)!=="/")
if (file_exists('autolib'))
if (file_exists('eclib') && SmartyHelper::getInstance()->get('project_has_directory') === null)
if (file_exists('emaxlib'))
if (file_exists('eventlib/utility/EnvironmentIdentifierUtil.php') || file_exists('emaxlib/utility/EnvironmentIdentifierUtil.php'))
if (file_exists('smarty3/Smarty.class.php'))
if (function_exists("hash_algos") and in_array("sha512",hash_algos()))
if (is_array($name)) {
if (is_bool($accesses))
if (is_file($configFile)) {
if (is_string($access))
if (is_string($accesses))
if (isset($_POST[$csrf_key]))
if (isset($_REQUEST[AuthUtility::getAuthKey()]))
if (isset($_REQUEST[self::AJAX_PARAM])
if (isset($_SERVER['HTTPS']))
if (isset($_SESSION))
if (isset($_SESSION['create_time']) && time() - $_SESSION['create_time'] >= $sessionTimeout*60)
if (isset($_SESSION[self::SESSION_USER]))
if (isset($location) && $location != "")
if (isset($loginPage))
if (isset($name) && $name != "")
if (isset($name)) {
if (isset($template) && $template != "")
if (isset($this->database) && $this->database !== false)
if (isset($this->database))
if (isset($this->session))
if (isset($this->user))
if (self::getConfigParam('log'))
if (self::getConfigParam('log_cookie'))
if (self::getConfigParam('log_get'))
if (self::getConfigParam('log_post'))
if (self::getConfigParam('log_remote_addr'))
if (self::getConfigParam('log_user_agent'))
if (self::getConfigParam(self::ENABLE_CONFIG_PARAM))
if (self::getConfigParam(self::FORCE_COMPILE_PARAM) == true)
if (self::getConfigParam(self::PAGE_VISIT_LOGGING) && !$this->pageVisitLogged && isset($this->database)) {
if (session_id() !== "")
if (strcasecmp($key, $source) == 0) {
if (stripos($class, 'ApnsPHP') === 0)
if (stripos($className, 'IndexPage') === false && !empty($_SESSION[self::SESSION_USER]) && $_SESSION[self::SESSION_USER] instanceof Webuser && $this->config instanceof ConfigUtil)
if (strpos($loginPage, 'http') === 0) // Do not include ?params=params if redirecting to external login page
if (strpos(Smarty::SMARTY_VERSION, '3.1') !== false)
if (strpos(strtolower($class), 'smarty_') !== 0) {
if($config===null)
if($this->config->getConfig('analytics.server_side_enable', false))
if(isset($_ENV["CONFIG_$name"]))
if(stream_resolve_include_path("$class.php")!==false)
if(substr($dir,-1)!='/')
include "pchart/class/$class.class.php";
ini_set("include_path", ini_get("include_path") .
ini_set('session.cookie_httponly', true);
ini_set('session.cookie_secure', true);
print_r($e);
print_r($spew);
protected $analyticsInterface = null;
protected $config;
protected $database;
protected $force_ssl = false;
protected $pageAccesses = false;
protected $pageVisitLogged = false;
protected $save_url = true;
protected $session_handler;
protected $smarty;
protected $user;
protected function assign($name, $value=null)
protected function checkForPause($wait = true) {
protected function createUserSession(&$user)
protected function destroyUserSession()
protected function dieString($string)
protected function displayTemplate($template)
protected function getCSRFToken()
protected function getEmailSaveDirectory()
protected function getForceSSL()
protected function getPageAccess()
protected function getSmartyVersion()
protected function getUserSession($loginPage=null)
protected function header($string)
protected function httpAuth($realm, $passwd) {
protected function insertPageVisit()
protected function isAjaxRequest()
protected function isDemo()
protected function isDev()
protected function isProduction()
protected function logPageView()
protected function logRequest()
protected function postCSRFCheck()
protected function postCheck()
protected function purify($html, $configSetArray = array())
protected function redirect($location)
protected function saveURL()
protected function setCSRFToken()
protected function setSessionCookieParams()
protected function setSessionHandler(SessionHandlerInterface $session_handler, $register_shutdown = true) {
protected function setSessionName()
protected function unassign($name)
protected function validateCSRFToken()
protected function validateUserAccess(Webuser $user)
protected function write($string)
protected static $configParams;
protected static $sessionName;
protected static $sessionNameSuffix;
public function display()
public function handleDisplayError($errno, $errstr, $errfile, $errline)
public function setPageAccess($access)
public static function getConfigParam($name)
public static function setRootPath($path)
public static function setSessionNameSuffix($sessionNameSuffix)
public static function setupConfig()
public static function smartyReadConfig($params, &$smarty)
public static function vomit($spew)
require "$class.php";
require_once  PROJECT_PHP_DIR.'eventlib/database/Log.php';
require_once '/usr/local/share/smarty/Smarty.class.php';
require_once 'htmlpurifier/library/HTMLPurifier.auto.php';
require_once 'smarty3/Smarty.class.php';
require_once(__DIR__.'/../utility/HttpBuildUrl.php');
restore_error_handler();
return !file_exists($lock);
return $_ENV["CONFIG_$name"];
return $authorized;
return $csrf_token;
return $db;
return $directory;
return $purifier->purify($html);
return $result;
return $this->csrfguard_validate_token($csrf_key, $csrf_token);
return $this->pageAccesses;
return $this->user;
return $token;
return EnvUtil::isDemo();
return EnvUtil::isDev();
return EnvUtil::isProd();
return false;
return null;
return self::$configParams[$name];
return self::SMARTY_2;
return self::getConfigParam(self::FORCE_SSL);
return true;
return true; // no session data, no CSRF Risk
return;
self::$configParams = parse_ini_file($configFile);
self::$sessionNameSuffix = $sessionNameSuffix;
self::DB_DSN_PARAM => self::getConfigParam(self::DB_DSN_PARAM),
self::DB_PASSWORD_PARAM => self::getConfigParam(self::DB_PASSWORD_PARAM)
self::DB_USER_PARAM => self::getConfigParam(self::DB_USER_PARAM),
session_destroy();
session_name($name);
session_name(self::DEFAULT_SESSION_NAME);
session_name(self::getConfigParam(self::SESSION_NAME_PARAM) . self::$sessionNameSuffix);
session_set_save_handler($this->session_handler, $register_shutdown);
session_start();
session_write_close();
set_error_handler(array($this, 'handleDisplayError'), E_ALL|~E_STRICT);
set_time_limit(0);
setcookie(session_name(), "", time() - 3600, $params['path'], $params['domain']);
shell_exec("/usr/local/bin/sudo /bin/mkdir templates_c && /usr/local/bin/sudo /usr/sbin/chown www templates_c");
shell_exec('/usr/local/bin/sudo /bin/mkdir -m 777 pchart/cache');
sleep(1);
spl_autoload_register('template_autoload');
static protected function openDatabase($config=null)
switch ($class)
throw new CSRFException();
throw new Exception ("Unable to create Email Save Directory $directory.");
throw new Exception ("Unable to find Email Save Directory.  No destination_dir directory set in config file.");
throw new Exception ("Unable to find destination_dir, login disabled");
throw new Exception("Could not open configuration file: " . $configFile);
throw new Exception("Database DSN parameter must be specified in configuration file or in an environment variable.");
throw new Exception("Invalid class name.");
throw new Exception("You are not authorized to view this page.", self::ACCESS_DENIED);
throw new PostException();
trigger_error('Deprecated function: '.__CLASS__.'::'.__FUNCTION__);
try
try {
unset($_SESSION[$key]);
unset($this->user);
while (file_exists($lock)) {
{
}
} else {
} elseif ($name !== '') {
