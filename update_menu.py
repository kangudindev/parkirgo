import io

with open('d:/parkirgo/backend/resources/js/Components/menu.vue', 'r', encoding='utf-8') as f:
    lines = f.readlines()

lines = lines[:214]
lines.extend([
    '        <li class="nav-item">\n',
    '          <Link href="/parkirgo/users" class="nav-link menu-link">\n',
    '            <i class="ri-user-settings-line"></i>\n',
    '            <span>Manajemen Pengguna</span>\n',
    '          </Link>\n',
    '        </li>\n',
    '        <li class="nav-item">\n',
    '          <Link href="/parkirgo/audit" class="nav-link menu-link">\n',
    '            <i class="ri-history-line"></i>\n',
    '            <span>Audit Log</span>\n',
    '          </Link>\n',
    '        </li>\n',
    '      </ul>\n',
    '    </template>\n',
    '  </BContainer>\n',
    '</template>\n'
])

with open('d:/parkirgo/backend/resources/js/Components/menu.vue', 'w', encoding='utf-8') as f:
    f.writelines(lines)
