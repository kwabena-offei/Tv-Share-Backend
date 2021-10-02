import { Table } from 'antd';
import { ExportOutlined, UserOutlined, AppleOutlined, GoogleOutlined, FacebookOutlined, MailOutlined, BranchesOutlined } from '@ant-design/icons';
import { Avatar } from 'antd';

// {
//   apple_id: null
//   bio: "Dwayne Douglas Johnson, also known as The Rock"
//   birth_date: null
//   cable_provider: null
//   city: null
//   comments_count: 4
//   created_at: "2020-10-05T00:47:27.831Z"
//   email: "funkparliament2@gmail.com"
//   facebook_id: null
//   followed_users_count: 1
//   followers_count: 1
//   gender: null
//   google_id: null
//   id: 5
//   image: "https://m.media-amazon.com/images/M/MV5BMTkyNDQ3NzAxM15BMl5BanBnXkFtZTgwODIwMTQ0NTE@._V1_UX214_CR0,0,214,317_AL_.jpg"
//   likes_count: 2
//   name: null
//   password_digest: "$2a$12$qD2bCqFAO3rv8X9IrWGn7.B.uThLR2Vzb6fh4sIW6rEvLAheYgspO"
//   password_reset_token: null
//   password_reset_token_expiration: null
//   phone_number: null
//   streaming_service: null
//   updated_at: "2021-05-12T02:38:07.722Z"
//   username: "the.rock"
// }

const columns = [
  {
    render: (text, record, index) => {
      return record.image ? <Avatar src={record.image} /> : <Avatar icon={<UserOutlined />} />;
    }
  },
  {
    title: 'Username',
    dataIndex: 'username',
    // specify the condition of filtering result
    // here is that finding the name started with `value`
    onFilter: (value, record) => record.username.indexOf(value) === 0,
    sorter: (a, b) => a.username.localeCompare(b.username),
    sortDirections: ['descend'],
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
    title: '# Comments',
    dataIndex: 'comments_count',
    defaultSortOrder: 'descend',
    sorter: {
      compare: (a, b) => (a.comments_count || 0) - (b.comments_count || 0),
    },
    render: (text, record, index) => {
      return text || '-';
    }
  },
  {
    title: 'Login',
    dataIndex: 'login_type',
    filters: [
      {
        text: 'Email',
        value: 'Email'
      },
      {
        text: 'Google',
        value: 'Google'
      },
      {
        text: 'Facebook',
        value: 'Facebook'
      },
      {
        text: 'Apple',
        value: 'Apple'
      }
    ],
    // specify the condition of filtering result
    // here is that finding the name started with `value`
    onFilter: (value, record) => record.login_type.indexOf(value) === 0,
    sorter: (a, b) => a.login_type.localeCompare(b.login_type),
    sortDirections: ['descend'],
    render: (text, record, index) => {
      if (record.login_type == 'Google') {
        return <GoogleOutlined />
      } else if (record.login_type == 'Facebook') {
        return <FacebookOutlined />
      } else if (record.login_type == 'Apple') {
        return <AppleOutlined />
      } else {
        return <MailOutlined />
      }
    }
  },
  {
    title: 'Zip',
    dataIndex: 'zipcode',
    sorter: (a, b) => (a.zipcode || 0) - (b.zipcode || 0),
    render: (text, record, index) => {
      return record.zipcode || '-'
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
      return <a href={`https://tvtalk.app/profiles/${record.username}`} target='tv_talk' alt='View Profile'><ExportOutlined /></a>
    }
  }
];

const data = [
  {
    key: '1',
    name: 'John Brown',
    age: 32,
    address: 'New York No. 1 Lake Park',
  },
  {
    key: '2',
    name: 'Jim Green',
    age: 42,
    address: 'London No. 1 Lake Park',
  },
  {
    key: '3',
    name: 'Joe Black',
    age: 32,
    address: 'Sidney No. 1 Lake Park',
  },
  {
    key: '4',
    name: 'Jim Red',
    age: 32,
    address: 'London No. 2 Lake Park',
  },
];

function onChange(pagination, filters, sorter, extra) {
  console.log('params', pagination, filters, sorter, extra);
}


const UsersTable = ({ users }) => {
  // const [form] = Form.useForm();

  return (
    <Table columns={columns} dataSource={users} onChange={onChange}>

    </Table>
  )
}

export default UsersTable;


