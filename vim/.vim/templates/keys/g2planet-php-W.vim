" g2planet

" Used absolutely everywhere

:append
        if (!empty($where)) {
            $sql .= ' where ' . implode(' and ', $where);
        }
.
