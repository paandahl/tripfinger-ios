import React from 'react';
import ReactNative from 'react-native';

const ListView = ReactNative.ListView;
const View = ReactNative.View;

export default class ListViewContainer extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    dataSource: React.PropTypes.object.isRequired,
    renderRow: React.PropTypes.func.isRequired,
    style: React.PropTypes.any,
  };

  constructor(props) {
    super(props);
    this.sectionPointer = 0;
    this.firstRowInSectionPointer = 0;
  }

  _isLastRowInSection(sectionId, rowId) {
    const startingPoint = this.sectionPointer;
    const sectionLengths = this.props.dataSource.getSectionLengths();
    do {
      const testSectionId =
        this.props.dataSource.getSectionIDForFlatIndex(this.firstRowInSectionPointer);
      if (testSectionId === sectionId) {
        const sectionLength = sectionLengths[this.sectionPointer];
        return parseInt(rowId, 10) === sectionLength - 1;
      } else if (testSectionId) {
        this.firstRowInSectionPointer += sectionLengths[this.sectionPointer];
        this.sectionPointer += 1;
      } else {
        this.firstRowInSectionPointer = 0;
        this.sectionPointer = 0;
      }
    } while (this.sectionPointer !== startingPoint);
    throw new Error(`sectionId not found in dataSource: ${sectionId}`);
  }

  _renderRow = (data, sectionId, rowId) => {
    const isFirstRow = rowId === '0';
    const isLastRow = this._isLastRowInSection(sectionId, rowId);
    return this.props.renderRow(data, sectionId, isFirstRow, isLastRow);
  };

  render() {
    return (
      <ListView
        dataSource={this.props.dataSource}
        style={this.props.style}
        renderRow={this._renderRow}
      />
    );
  }
}
