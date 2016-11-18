import React from 'react';
import ReactNative from 'react-native';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class SearchResultCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    result: React.PropTypes.object.isRequired,
    onPress: React.PropTypes.func,
    isFirstRow: React.PropTypes.bool,
    isLastRow: React.PropTypes.bool,
    firstRowInSectionStyle: React.PropTypes.any,
  };

  _renderGuideBadge() {
    if (!this.props.result.tripfingerId) {
      return null;
    }
    return <View style={styles.guideBadge}><Text style={styles.guideBadgeText}>Guide</Text></View>;
  }

  render() {
    const rowStyles = [styles.row];
    if (this.props.isFirstRow) {
      if (this.props.firstRowInSectionStyle) {
        rowStyles.push(this.props.firstRowInSectionStyle);
      } else {
        rowStyles.push(styles.firstRowInSection);
      }
    }
    if (this.props.isLastRow) {
      rowStyles.push(styles.lastRowInSection);
    }
    return (
      <TouchableHighlight
        style={rowStyles}
        underlayColor="#DDDDDD"
        onPress={this.props.onPress}
      >
        <View style={styles.innerRow}>
          <View>
            <Text style={styles.name}>{this.props.result.string}</Text>
            {this._renderGuideBadge()}
          </View>
          <Text style={styles.type}>{this.props.result.typeStr}</Text>
          <Text style={styles.address}>{this.props.result.address}</Text>
        </View>
      </TouchableHighlight>
    );
  }
}

const styles = StyleSheet.create({
  row: {
    paddingLeft: 23,
    height: 80,
    backgroundColor: '#FFFFFF',
  },
  firstRowInSection: {
    marginTop: 20,
  },
  lastRowInSection: {
    borderBottomWidth: 0.5,
    borderBottomColor: '#ccc',
  },
  innerRow: {
    height: 80,
    justifyContent: 'center',
    borderBottomWidth: 0.5,
    borderBottomColor: '#ccc',
  },
  rowHighlight: {
    flex: 1,
  },
  name: {
    fontSize: 16,
    fontWeight: '500',
  },
  guideBadge: {
    position: 'absolute',
    top: 0,
    right: 10,
    width: 80,
    height: 22,
    borderRadius: 3,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#ccc',
  },
  guideBadgeText: {
    color: '#fff',
  },
  type: {
    marginTop: 3,
    fontSize: 13,
    color: '#777',
  },
  address: {
    marginTop: 10,
    fontSize: 13,
    color: '#777',
  },
});
