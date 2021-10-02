import { Layout, Menu, Breadcrumb, Sider, PageHeader } from 'antd';

import UsersTable from "./users/Table";
// import Shows from "./users/Shows";
// import UserSorter from "./users/UserSorter";
import {useState, useEffect} from "react";
import { Button, Space } from 'antd';

const { Header, Content, Footer } = Layout;

const Users= () => {
  const [users, setUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);

  useEffect(() => {
   getUsers().then(users => {
     setUsers(users)
   })
}, [selectedUser])

  const updateUsers = (_users) => {
    setUsers(_users);
    _users.forEach((user, i) => {
      const url = `/admin/users/${user.id}.json`;
      const data = { user: { position: i } }

      fetch(url, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      }).then(response => response.json())
      .then(data => {
      });
    })
  }

  return (
    <Layout className="layout">
      <Header>
        <div className="logo" />
        <Menu theme="dark" mode="horizontal" defaultSelectedKeys={['home']}>
          <Menu.Item key="home" onClick={() => setSelectedUser(null) }>All Users</Menu.Item>
          <Menu.Item key="form"></Menu.Item>
          {users.map((user, i) => {
            return <Menu.Item key={i} onClick={() => setSelectedUser(user)}>{user.title}</Menu.Item>
          })}
        </Menu>
      </Header>
      <Content style={{ padding: '0 50px' }}>
      <PageHeader title="Users" />
        <div className="site-layout-content">{selectedUser ? <Shows user={selectedUser} onDelete={() => setSelectedUser(null) }/> : ''}</div>
        <UsersTable users={users}/>
      </Content>
      <Footer style={{ textAlign: 'center' }}>TV Talk</Footer>
    </Layout>
  );
}

export default Users;

function getUsers() {
  return fetch('/admin/users.json')
    .then(data => data.json())
}
