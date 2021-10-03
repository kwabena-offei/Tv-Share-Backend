import { Layout, Menu, Breadcrumb, PageHeader } from 'antd';

import AdminLayout from "../Layout";
import CommentsTable from "./comments/Table";
import { useState, useEffect } from "react";

const { Header, Content, Footer } = Layout;

const Comments = () => {
  const [comments, setComments] = useState([]);
  const [selectedComment, setSelectedComment] = useState(null);

  useEffect(() => {
    getComments().then(comments => {
      setComments(comments)
    })
  }, [selectedComment])

  const updateComments = (_comments) => {
    setComments(_comments);
    _comments.forEach((comment, i) => {
      const url = `/admin/comments/${comment.id}.json`;
      const data = { comment: { position: i } }

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
    <AdminLayout selectedMenuItem='comments'>
      <Header>
        <div className="logo" />
        <Menu theme="dark" mode="horizontal" defaultSelectedKeys={['home']}>
          <Menu.Item key="home" onClick={() => setSelectedComment(null)}>All Comments</Menu.Item>
          <Menu.Item key="form"></Menu.Item>
          {comments.map((comment, i) => {
            return <Menu.Item key={i} onClick={() => setSelectedComment(comment)}>{comment.title}</Menu.Item>
          })}
        </Menu>
      </Header>

      <Content style={{ padding: '0 50px' }}>
        <PageHeader title="Comments" />
        <div className="site-layout-content">{selectedComment ? <Shows comment={selectedComment} onDelete={() => setSelectedComment(null)} /> : ''}</div>
        <CommentsTable comments={comments} />
      </Content>
    </AdminLayout>
  );
}

export default Comments;

function getComments() {
  return fetch('/admin/comments.json')
    .then(data => data.json())
}
