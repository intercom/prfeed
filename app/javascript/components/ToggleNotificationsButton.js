import React, { Component } from 'react';

class ToggleNotificationsButton extends Component {
  notificationsDisabled () {
    return !window.Notification || Notification.permission === 'denied'
  }

  notificationsEnabled () {
    return Notification.permission === 'granted'
      && localStorage.getItem('sendNotifications')
  }

  async tryEnableNotifications () {
    const status = await Notification.requestPermission()

    if (status === 'granted') {
      new Notification(
        "Great!",
        { body: "PRFeed will now notify you when new PRs pop up." },
      )
      localStorage.setItem('sendNotifications', true)
    }

    this.forceUpdate()
  }

  disableNotifications () {
    localStorage.removeItem('sendNotifications')
    this.forceUpdate()
  }

  handleClick () {
    if (this.notificationsEnabled()) {
      this.disableNotifications()
    } else {
      this.tryEnableNotifications()
    }
  }

  render() {
    if (this.notificationsDisabled()) return null

    return (
      <button className="button o__secondary" onClick={() => this.handleClick()}>
        {this.notificationsEnabled()
          ? 'Disable notifications'
          : 'Enable notifications'}
      </button>
    );
  }
}

export default ToggleNotificationsButton;
