import React from 'react';
import PropTypes from 'prop-types';
import { Button, Input } from 'antd';
import { Modal } from 'react-bootstrap';

const { Body, Footer, Header, Title } = Modal;

class SaveSearchButton extends React.Component {
  constructor () {
    super();

    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.handleInput = this.handleInput.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);

    this.state = {
      visible: false,
      name: '',
    };
  }

  openModal () {
    this.setState({ visible: true });
  }

  closeModal () {
    this.setState({ visible: false, name: '' });
  }

  handleInput (e) {
    this.setState({ name: e.target.value });
  }

  handleSubmit () {
    this.props.saveSearch(this.state.name);
    this.setState({ name: '', visible: false });
  }

  render () {
    const {
      canFetch,
    } = this.props;

    const { visible, name } = this.state;

    return (
      <span>
        <Button className="btn btn-primary" disabled={!canFetch} onClick={this.openModal}>Save Search</Button>

        <Modal onHide={this.closeModal} show={visible} className="save-search-modal">
          <Header>
            <Title>
              Name your search
            </Title>
          </Header>
          <Body>
            <Input
              autoFocus
              onChange={this.handleInput}
              onPressEnter={this.handleSubmit}
              placeholder="Name your search"
              value={name}
            />
          </Body>
          <Footer>
            <Button className="btn btn-primary" onClick={this.handleSubmit}>Create Search</Button>
            <Button className="btn btn-primary" onClick={this.closeModal}>Cancel</Button>
          </Footer>
        </Modal>
      </span>
    );
  }
}

SaveSearchButton.propTypes = {
  canFetch: PropTypes.bool.isRequired,
  saveSearch: PropTypes.func.isRequired,
};

export default SaveSearchButton;
