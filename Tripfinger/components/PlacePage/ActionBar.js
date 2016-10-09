// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';

const Component = React.Component;
const PropTypes = React.PropTypes;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;
const addBookmarkImage = require('../../assets/bookmark_add.png');
const routeImage = require('../../assets/ic_route.png');
// </editor-fold>

export default class ActionBar extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    info: PropTypes.object,
  };

  constructor(props) {
    super(props);
    this.actionView = <View />;
  }

  // noinspection JSMethodCanBeStatic
  render() {
    if (this.props.info !== null) {
      this.actionView = (
        <View style={styles.actionBar}>
          <View style={styles.actionButton}>
            <Image source={addBookmarkImage} style={styles.buttonIcon} />
            <Text style={styles.buttonText}>Save</Text>
          </View>
          <View style={styles.actionButton}>
            <Image source={routeImage} style={styles.buttonIcon} />
            <Text style={styles.buttonText}>Route</Text>
          </View>
        </View>
      );
    }

    return this.actionView;
  }
}

const styles = StyleSheet.create({
  actionBar: {
    height: 47,
    backgroundColor: '#EEE',
    borderTopWidth: 1,
    borderTopColor: '#DDD',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  actionButton: {
    marginTop: 2,
    width: 150,
    alignItems: 'center',
  },
  buttonIcon: {
    tintColor: '#5D5D5D',
  },
  buttonText: {
    fontSize: 11,
    color: '#777',
  },
});
