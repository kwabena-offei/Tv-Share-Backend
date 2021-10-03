import { Table } from 'antd';
import { ExportOutlined, CommentOutlined, userOutlined, WarningTwoTone } from '@ant-design/icons';
import { Avatar } from 'antd';

const columns = [
  {
    render: (text, record, index) => {
      return <a href={`https://tvtalk.app/profiles/${record.user?.username}`} target='tv_talk' alt='View Profile'>
        {record.user?.image ? <Avatar src={record.user.image} /> : <Avatar icon={<UserOutlined />} />}
      </a>
    }
  },
  {
    title: '# Likes',
    dataIndex: 'likes_count',
    defaultSortOrder: 'descend',
    sorter: {
      compare: (a, b) => (a.likes_count || 0) - (b.likes_count || 0),
    },
    render: (text, record, index) => {
      return text || '-';
    }
  },
  {
    title: '# Images',
    dataIndex: 'image_count',
    defaultSortOrder: 'descend',
    sorter: {
      compare: (a, b) => a.image_count - b.image_count,
    },
    render: (text, record, index) => {
      return text || '-';
    }
  },
  {
    title: '# Videos',
    dataIndex: 'video_count',
    defaultSortOrder: 'descend',
    sorter: {
      compare: (a, b) => a.video_count - b.video_count,
    },
    render: (text, record, index) => {
      return text || '-';
    }
  },
  {
    title: 'Profanity',
    dataIndex: 'has_profanity',
    filters: [
      {
        text: 'Contains Profanity',
        value: true
      }
    ],
    // specify the condition of filtering result
    // here is that finding the name started with `value`
    onFilter: (value, record) => record.has_profanity === value,
    render: (text, record, index) => {
      if (record.has_profanity) {
        return <WarningTwoTone twoToneColor="#FF7900"/>
      }
    }
  },
  {
    title: 'Created',
    dataIndex: 'created_at',
    sorter: (a, b) => Date.parse(a.created_at) - Date.parse(b.created_at),
    render: (text, record, index) => {
      return new Date(record.created_at).toLocaleDateString()
    }
  },
  {
    title: 'Visit',
    key: 'id',
    dataIndex: 'id',
    render: (text, record, index) => {
      let url;

      if (record.story_id)
        url = `https://tvtalk.app/news/story/${record.show_id}#comment_${record.id}`
      else {
        url = `https://tvtalk.app/networks/network/programs/${record.show_id}/comments/${record.id}`
      }
      return <a href={url} target='tv_talk' alt='View Comment'><ExportOutlined /></a>
    }
  }
];

const CommentsTable = ({ comments }) => {

  return (
    <Table
      key='comments'
      rowKey='id'
      columns={columns}
      dataSource={comments}
      expandable={{
        defaultExpandAllRows: true,
        expandedRowRender: record => {
          return <div>
                <div>{record.images?.map((image) => <img src={image} />)}</div>
                <p style={{ margin: 0 }}>{record.text}</p>
                </div>
        },
        rowExpandable: record => true,
      }}  
      defaultExpandAllRows={true}
      expandedRowKeys={comments.map((comment) => comment.id)}
    >

    </Table>
  )
}

export default CommentsTable;


