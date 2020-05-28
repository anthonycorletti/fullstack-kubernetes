import React from 'react';
import MessageIcon from '@material-ui/icons/Message';
import ItemIcon from '@material-ui/icons/PostAdd';
import { Admin, Resource } from 'react-admin';
import simpleRestProvider from 'ra-data-simple-rest';

import { ItemList, ItemEdit, ItemCreate, ItemShow } from './items';
import { MessageList, MessageCreate } from './messages';
import Dashboard from './Dashboard';
import authProvider from './authProvider';

const App = () => (
    // this provider should be the api endpoint which can be configured in
    // vault and set at run time/ build time/ etc
    <Admin
        dataProvider={simpleRestProvider(
            `http://${window.location.host}/api/v1`
        )}
        authProvider={authProvider}
        dashboard={Dashboard}
    >
        <Resource
            name="items"
            icon={ItemIcon}
            list={ItemList}
            edit={ItemEdit}
            create={ItemCreate}
            show={ItemShow}
        />

      <Resource
          name="messages"
          icon={MessageIcon}
          list={MessageList}
          create={MessageCreate}
      />
    </Admin>
);
export default App;
