<?php

class EcModuleAgent {

    protected
        $config
        ,$user
        ,$database
        ;

    private
        $enabled_modules
        ,$licensed_modules
        ,$user_visible_modules
        ,$enabled_roles
        ,$user_visible_roles
        ;

    public function setConfig(ConfigUtil $config) {
        $this->config = $config;
    }

    /**
     * @param Person $user The person accessing the system
     */
    public function setUser(Person $user) {
        $this->user = $user;
    }

    public function setDatabase(PDO $database) {
        $this->database = $database;
    }

    /**
     * @return string[] Array of enabled modules in the system.
     * @throws Exception In the case of invalid state.
     */
    public function getEnabledModules() {
        if (!isset($this->enabled_modules)) {
            $this->checkConfig();
            $this->enabled_modules = $this->config->getConfig('event_central.enabled_modules', []);
        }

        return $this->enabled_modules;
    }

    /**
     * @return string[] Array of licensed modules in the system.
     * @throws Exception In the case of invalid state.
     */
    public function getLicensedModules() {
        if (!isset($this->licensed_modules)) {
            $this->checkConfig();
            $this->checkUser();
            $enabled_modules = $this->getEnabledModules();

            // bypass check if user has special access
            if ($this->user->hasAccess('view_unlicensed_modules')) {
                $this->licensed_modules = $enabled_modules;
            }
            else {
                $licensed_modules = $this->config->getConfig('event_central.licensed_modules', []);
                $this->licensed_modules = array_intersect($enabled_modules, $licensed_modules);
            }

        }

        return $this->licensed_modules;
    }

    /**
     * @return string[] Array of modules the user can see.
     * @throws Exception In the case of invalid state.
     */
    public function getUserVisibleModules() {
        if (!isset($this->user_visible_modules)) {
            $this->checkUser();
            $this->checkDatabase();

            $extraWhere = [];
            $extraParams = [];

            $module_codes = $this->getLicensedModules();
            if (empty($module_codes)) {
                return [];
            }
            $extraWhere[] = "menu_value in ("
                . implode(',', array_fill(0, count($module_codes), '?')) .
            ")";
            $extraParams = array_merge($extraParams, $module_codes);

            // only retrieve the top-level menus
            $extraWhere[] = 'parent_menu_id is null';

            // hide demoware menus from view if configured
            // (this is a partial solution to the EC menu duplication-for-each-client problem)
            if (!$this->config->getConfig('event_central_demoware.enabled', false)) {
                $extraWhere[]=
                    "coalesce(is_hidden, 'f') = 'f'";
            }

            // use the DTO class's item grabbing script to retrieve all top-level menus
            $fakeMenu = new Menu;
            $fakeMenu->getItems($this->database, $this->user, false, $extraWhere, $extraParams);

            // limit to menu_value only
            $this->user_visible_modules =
                array_reduce(
                    $fakeMenu->items,
                    function (&$carry, &$item) {
                        $carry[] = $item->menu_value;
                        return $carry;
                    },
                    []
                );
        }

        return $this->user_visible_modules;
    }

    /**
     * Get all top-level menus.
     *
     * If the menu code is disabled via configuration value
     * "event_central.enabled_modules" or "event_central.licensed_modules" it
     * also won't be part of the menus returned.
     *
     * @return Menu[]
     * @throws Exception In the case of invalid state.
     */
    public function getTopLevelMenus() {

        $this->checkConfig();
        $this->checkDatabase();

        $extraWhere = [];
        $extraParams = [];

        // limit to only the modules the user can see
        $module_codes = $this->getUserVisibleModules();
        if (empty($module_codes)) {
            return [];
        }
        $extraWhere[] = "menu_value in ("
            . implode(',', array_fill(0, count($module_codes), '?')) .
        ")";
        $extraParams = array_merge($extraParams, $module_codes);

        // only retrieve the top-level menus
        $extraWhere[] = 'parent_menu_id is null';

        // hide demoware menus from view if configured
        // (this is a partial solution to the EC menu duplication-for-each-client problem)
        if (!$this->config->getConfig('event_central_demoware.enabled', false)) {
            $extraWhere[]=
                "coalesce(is_hidden, 'f') = 'f'";
        }

        // use the DTO class's item grabbing script to retrieve all top-level menus
        $fakeMenu = new Menu;
        $fakeMenu->getItems($this->database, null, false, $extraWhere, $extraParams);

        return $fakeMenu->items;
    }

    /**
     * Return all Role records available to the system.
     *
     * Some Roles are supposed to be disabled because the Program Management
     * module they're associated with is disabled at a system level.
     *
     * @param string $sort How to sort the roles
     * @return Role[]
     * @throws Exception In the case of invalid state.
     */
    public function getEnabledRoles($sort = null) {

        if (!isset($sort)) {
            $sort = "
                module_code,
                (select count(*) from role_access ra where ra.role_id = x.role_id) asc
            ";
        }

        if (!isset($this->enabled_roles)) {
            $this->checkDatabase();

            $enabled_modules = $this->getEnabledModules();
            $module_codes = preg_replace(
                '/;/',
                '_',
                $enabled_modules
            );

            // Strategy and Planning Roles do not follow
            // "pman_name;Name" format (empty module_code)
            $module_codes = preg_replace(
                '/snp_.*/',
                '',
                $module_codes
            );

            $where_mods = [
                "module_code in (" .
                    implode(',', array_fill(0, count($module_codes), '?')) . # (?,?,?,...)
                ")",
            ];
            $params = $module_codes;

            $where = 'where ' . implode(' or ', $where_mods);

            $sql = "
                select
                    *
                from (
                    select
                        role.*,

                        (case when role_name ~ ';' then
                            regexp_replace(role_name, ';.*$', '')
                        else
                            ''
                        end) as module_code

                    from
                        role
                ) x
                $where
                order by $sort
            ";
            $stmt = $this->database->prepare($sql);
            $stmt->execute($params);
            $stmt->setFetchMode(PDO::FETCH_CLASS, 'Role');
            $this->enabled_roles = $stmt->fetchAll();
        }

        return $this->enabled_roles;

    }

    /**
     * Apply business logic to mesh user visible modules and user roles
     * enabled in the system.
     *
     * @return Role[] The roles the user can see, for instance on their profile
     * or on the New User wizard.
     * @throws Exception In the case of invalid state.
     */
    public function getUserVisibleRoles($sort = null) {
        if (!isset($this->user_visible_roles)) {
            $user_visible_modules = $this->getUserVisibleModules();
            $enabled_roles = $this->getEnabledRoles($sort);

            $userVisibleRolePrefixes = [];
            foreach ($user_visible_modules as $menu_value) {
                switch ($menu_value) {
                    case 'snp;ecal':
                    case 'snp;pplan':
                    case 'snp;enviro':
                        $rolePrefix = '';
                        break;
                    default:
                        $rolePrefix = preg_replace('/;/', '_', $menu_value);
                        break;
                }

                $userVisibleRolePrefixes[] = $rolePrefix;
            }
            $userVisibleRolePrefixes = array_unique($userVisibleRolePrefixes);

            $userVisibleRoles = [];
            foreach ($enabled_roles as $role) {
                $rolePrefix = '';
                $roleParts = [];
                if (preg_match('/^(.*);/', $role->role_name, $roleParts)) {
                    $rolePrefix = $roleParts[1];
                }
                if (in_array($rolePrefix, $userVisibleRolePrefixes)) {
                    $userVisibleRoles[] = $role;
                }
            }
            $this->user_visible_roles = $userVisibleRoles;
        }

        return $this->user_visible_roles;
    }

    private function checkConfig() {
        if (!isset($this->config)) {
            throw new Exception("'config' member not set");
        }
    }

    private function checkDatabase() {
        if (!isset($this->database)) {
            throw new Exception("'database' member not set");
        }
    }

    private function checkUser() {
        if (!isset($this->user)) {
            throw new Exception("'user' member not set");
        }

        if (!isset($this->user->accesses)) {
            throw new Exception("'user' member not prepared (no accesses)");
        }
    }

}
