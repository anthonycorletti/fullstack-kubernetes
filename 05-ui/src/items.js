import React from 'react';
import {
    Show,
    ShowButton,
    SimpleShowLayout,
    DateField,
    List,
    Edit,
    Create,
    Datagrid,
    TextField,
    EditButton,
    SimpleForm,
    TextInput,
} from 'react-admin';

export const ItemList = props => (
    <List {...props} >
        <Datagrid>
            <TextField source="id" />
            <TextField source="name" />
            <TextField source="description" />
            <DateField source="created_at" />
            <DateField source="updated_at" />
            <EditButton />
            <ShowButton />
        </Datagrid>
    </List>
);

const ItemTitle = ({ record }) => {
    return <span>Item {record ? `"${record.name}"` : ''}</span>;
};

export const ItemEdit = props => (
    <Edit title={<ItemTitle />} {...props}>
        <SimpleForm>
            <TextInput disabled source="id" />
            <TextInput source="name" />
            <TextInput multiline source="description" />
        </SimpleForm>
    </Edit>
);

export const ItemCreate = props => (
    <Create {...props}>
        <SimpleForm>
            <TextInput source="name" />
            <TextInput multiline source="description" />
        </SimpleForm>
    </Create>
);

export const ItemShow = props => (
    <Show {...props}>
        <SimpleShowLayout>
            <TextField source="id" />
            <TextField source="name" />
            <TextField source="description" />
            <DateField source="created_at" />
            <DateField source="updated_at" />
        </SimpleShowLayout>
    </Show>
);
