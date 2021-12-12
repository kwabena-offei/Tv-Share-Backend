import { Form, Input, Button } from 'antd';
import { useState } from "react";
// import { PickerOverlay } from 'filestack-react'

const UserForm = () => {
  const [showFilePicker, setShowFilePicker] = useState(false)
  const [profileImageURL, setProfileImageURL] = useState(null)
  const handleAddPhotoButtonClick = () => setShowFilePicker(true)
  const handleFilePickerClose = () => setShowFilePicker(false)

  const onFinish = (values) => {
    console.log('Success:', values);
    fetch('/admin/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ user: values })
    }).then(response => response.json())
      .then(data => {
        console.log("Data is", data)
      });
  };

  const onFinishFailed = (errorInfo) => {
    console.log('Failed:', errorInfo);
  };

  const handleFileUpload = ({ uploadedFile }) => {
    setProfileImageURL(uploadedFile.url)
  }

  const stringFields = [
    { name: 'name', required: true },
    { name: 'username', required: true },
    { name: 'email', required: true },
    // { name: 'image', required: false },
    { name: 'password', required: true },
  ];

  return (
    <Form
      name="basic"
      labelCol={{ span: 8 }}
      wrapperCol={{ span: 16 }}
      initialValues={{ remember: true }}
      onFinish={onFinish}
      onFinishFailed={onFinishFailed}
      autoComplete="off"
    >
      {stringFields.map((field) => {
        return <Form.Item
          label={field.name}
          name={field.name}
          rules={[{ required: field.required, message: `Required` }]}
        >
          <Input />
        </Form.Item>
      })}

      <Button onClick={handleAddPhotoButtonClick} >
        Upload profile image
      </Button>

      {showFilePicker && (
        <PickerOverlay
          action="pick"
          apikey={'A9BFYCPNxQeKh3wqeVSYkz'}
          onSuccess={handleFileUpload}
          actionOptions={{
            accept: ['image/*', 'video/*'],
            maxFiles: 4
          }}
          pickerOptions={{
            onClose: handleFilePickerClose
          }}
        />
      )}

      <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
        <Button type="primary" htmlType="submit">
          Submit
        </Button>
      </Form.Item>
    </Form>
  );
};

export default UserForm;
