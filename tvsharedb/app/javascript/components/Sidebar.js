import { Layout, Menu } from 'antd';
const { Sider } = Layout;
import { UserOutlined, TagsOutlined } from '@ant-design/icons';

const Sidebar = ({selected}) => {
  return (
    <Sider>
      <Menu theme="dark" defaultSelectedKeys={[selected || 'users']} mode="inline">
      <Menu.Item key="users" icon={ <UserOutlined/> }>
          <a href="/admin/users">Users</a>
        </Menu.Item>
        <Menu.Item key="categories" icon={ <TagsOutlined/> }>
          <a href="/admin/categories">Categories</a>
        </Menu.Item>
      </Menu>
    </Sider>
  )
}

export default Sidebar;