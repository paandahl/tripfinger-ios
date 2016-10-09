import React from 'react';
import ReactNative from 'react-native';
import IconCell from '../ListCells/IconCell';
import ViewState from './PlacePageViewState';
import Utils from '../../modules/Utils';

const Component = React.Component;
const PropTypes = React.PropTypes;
const Image = ReactNative.Image;
const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const expandImage = require('../../assets/placepage_tip.png');
const collapseImage = require('../../assets/placepage_collapse.png');
const coordinatesIcon = require('../../assets/ic_placepage_coordinate.png');

export default class PlacePageInfo extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    headerClicked: PropTypes.func.isRequired,
    info: PropTypes.object,
    viewState: PropTypes.string.isRequired,
    panHandlers: PropTypes.any,
  };

  constructor(props) {
    super(props);
    this.state = {
      dataSource: Utils.simpleDataSource(),
    };
    this.featureView = <View />;
  }

  componentWillReceiveProps(newProps) {
    if (newProps.info) {
      this.fillDatasource(newProps.info);
    }
  }

  fillDatasource(info) {
    const lat = info.lat / 1000000;
    const lon = info.lon / 1000000;
    const data = { gps: { lat, lon } };

    this.setState({
      dataSource: this.state.dataSource.cloneWithRows(data, ['gps']),
    });
  }

  renderRow = (data, sectionId, rowId) => {
    if (rowId === 'gps') {
      const text = `${data.lat} ${data.lon}`;
      return <IconCell sectionId={sectionId} rowId={rowId} text={text} icon={coordinatesIcon} />;
    }
    return null;
  };

  // noinspection JSMethodCanBeStatic
  render() {
    const headerTip = this.props.viewState === ViewState.EXPANDED ? collapseImage : expandImage;
    if (this.props.info !== null) {
      this.featureView = (
        <View style={styles.info} {...this.props.panHandlers}>
          <TouchableHighlight
            style={styles.header}
            underlayColor="#FFF"
            onPress={this.props.headerClicked}
          >
            <View>
              <Image style={styles.tip} source={headerTip} />
              <Text style={styles.name}>{this.props.info.title}</Text>
              <View>
                <Text style={styles.type}>{this.props.info.category}</Text>
                <Text style={styles.distance}>968 km</Text>
              </View>
            </View>
          </TouchableHighlight>
          <View style={styles.featureDetails}>
            <ListView
              removeClippedSubviews={false}
              style={styles.featureList}
              dataSource={this.state.dataSource}
              renderRow={this.renderRow}
            />
          </View>
          <View style={styles.hiddenFooter} />
        </View>
      );
    }

    return this.featureView;
  }
}

const styles = StyleSheet.create({
  info: {
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  header: {
    height: 78,
    alignSelf: 'stretch',
    paddingLeft: 20,
    paddingRight: 20,
  },
  tip: {
    alignSelf: 'center',
  },
  name: {
    fontSize: 21,
    fontWeight: '500',
    marginTop: 4,
    marginBottom: 6,
  },
  type: {
    color: '#777',
  },
  distance: {
    position: 'absolute',
    top: 0,
    right: 0,
    fontWeight: '500',
    color: '#1C80EC',
  },
  featureDetails: {
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  featureList: {
    marginTop: 20,
    marginBottom: 20,
  },
  hiddenFooter: {
    height: 47,
  },
});
