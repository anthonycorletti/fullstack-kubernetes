import React from 'react';
import {
    List,
    Create,
    Datagrid,
    TextField,
    SimpleForm,
    TextInput,
    SaveButton,
    Toolbar
} from 'react-admin';
import MessageIcon from '@material-ui/icons/Message';

export const MessageList = props => (
    <List {...props} >
        <Datagrid>
            <TextField source="data" />
            <TextField source="created_at" />
        </Datagrid>
    </List>
);

const CreateMessageToolbar = props => (
    <Toolbar {...props} >
        <SaveButton
            label="send"
            icon={<MessageIcon />}
            redirect="list"
            submitOnEnter={true}
        />
    </Toolbar>
);


export const MessageCreate = props => (
    <Create {...props}>
        <SimpleForm redirect="list" toolbar={<CreateMessageToolbar />}>
            <TextInput source="data" />
        </SimpleForm>
    </Create>
);
