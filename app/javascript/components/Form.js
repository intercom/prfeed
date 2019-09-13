import React, { Component } from 'react';
import '../stylesheets/Form.css';

class Form extends Component {
  constructor() {
    super()

    this.state = {
      url: '',
      className: '',
      placeholder: 'Enter the Github URL of your PR',
      errorMessage: null,
    }

    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.handleSubmitSuccess = this.handleSubmitSuccess.bind(this)
    this.handleSubmitFailure = this.handleSubmitFailure.bind(this)
  }

  componentDidMount() {
    this.formInput.focus();
  }

  handleChange(event) {
    this.setState({
      url: event.target.value,
      className: '',
      errorMessage: null,
    });
  }

  handleSubmit(event) {
    event.preventDefault();
    let { url } = this.state
    if (url.length === 0) { return }
    fetch('pull_requests', {
      credentials: 'include',
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ pull_request: { url: url }})
    }).then(response => this.handleSubmitSuccess(response))
      .catch(() => this.handleSubmitFailure())
  }

  async handleSubmitSuccess(response) {
    let pullRequest = await response.json()
    this.props.addPullRequest(pullRequest)
    this.setState({
      url: '',
      className: '',
    });
  }

  handleSubmitFailure() {
    this.setState({
      url: '',
      className: 'o__error',
      errorMessage: 'Pull request not found',
    });
  }

  render() {
    return (
        <form className="form flex" onSubmit={this.handleSubmit}>
          <input
            className={`form__input__pull-request ${this.state.className}`}
            onChange={this.handleChange}
            placeholder={this.state.errorMessage || this.state.placeholder}
            ref={(input) => { this.formInput = input }}
            type="text"
            value={this.state.url} />
          <button type="submit" className="button o__pull-request">Post</button>
        </form>
    );
  }
}

export default Form;
