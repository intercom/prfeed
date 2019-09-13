import React, { Component } from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom'
import PrFeed from '../routes/PrFeed';
import ManageTeams from '../routes/ManageTeams';

class App extends Component {

  render() {
    return (
      <Router>
        <div>
          <Route exact path="/" component={PrFeed}/>
          <Route exact path="/manage_teams" component={ManageTeams}/>
        </div>
      </Router>
    )
  }
}

export default App;
