import React from 'react';
import ReactNative from 'react-native';
import IconCell from '../ListCells/IconCell';
import OpeningHoursCell from '../ListCells/OpeningHoursCell';
import ViewState from './PlacePageViewState';
import Utils from '../../modules/Utils';

const Image = ReactNative.Image;
const Linking = ReactNative.Linking;
const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const expandImage = require('../../assets/placepage/placepage_tip.png');
const collapseImage = require('../../assets/placepage/placepage_collapse.png');
const coordinatesIcon = require('../../assets/placepage/coordinates.png');
const phoneIcon = require('../../assets/placepage/number.png');
const websiteIcon = require('../../assets/placepage/website.png');
const emailIcon = require('../../assets/placepage/email.png');
const wifiIcon = require('../../assets/placepage/wifi.png');

export default class PlacePageInfo extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    headerClicked: React.PropTypes.func.isRequired,
    headerHeightUpdated: React.PropTypes.func.isRequired,
    info: React.PropTypes.object,
    viewState: React.PropTypes.string.isRequired,
    panHandlers: React.PropTypes.any,
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
    const data = {};
    const rows = [];
    if (info.phoneNumber) {
      data.phoneNumber = info.phoneNumber;
      rows.push('phoneNumber');
    }
    if (info.website) {
      data.website = info.website;
      rows.push('website');
    }
    if (info.email) {
      data.email = info.email;
      rows.push('email');
    }
    if (info.openHours) {
      data.openHours = info.openHours;
      rows.push('openHours');
    }
    const lat = info.lat / 1000000;
    const lon = info.lon / 1000000;
    data.gps = { lat, lon };
    rows.push('gps');
    this.setState({
      dataSource: this.state.dataSource.cloneWithRows(data, rows),
    });
  }

  renderRow = (data, sectionId, rowId) => {
    if (rowId === 'gps') {
      const text = `${data.lat} ${data.lon}`;
      return <IconCell sectionId={sectionId} rowId={rowId} text={text} icon={coordinatesIcon} />;
    } else if (rowId === 'phoneNumber') {
      return (
        <IconCell
          sectionId={sectionId} rowId={rowId} text={data} icon={phoneIcon} textStyle="link"
          onPress={() => Linking.openURL(`telprompt:${data}`)}
        />
      );
    } else if (rowId === 'website') {
      return (
        <IconCell
          sectionId={sectionId} rowId={rowId} text={data} icon={websiteIcon} textStyle="link"
          onPress={() => Linking.openURL(data)}
        />
      );
    } else if (rowId === 'email') {
      return (
        <IconCell
          sectionId={sectionId} rowId={rowId} text={data} icon={emailIcon} textStyle="link"
          onPress={() => Linking.openURL(`mailto:${data}`)}
        />
      );
    } else if (rowId === 'openHours') {
      return (
        <OpeningHoursCell openingHours={data} />
      );
    } else if (rowId === 'wifi') {
      return (
        <IconCell sectionId={sectionId} rowId={rowId} text="Yes" icon={wifiIcon} />
      );
    }
    return null;
  };

  render() {
    const headerTip = this.props.viewState === ViewState.EXPANDED ? collapseImage : expandImage;
    if (this.props.info !== null) {
      this.featureView = (
        <View style={styles.info} {...this.props.panHandlers}>
          <TouchableHighlight
            style={styles.header}
            underlayColor="#FFF"
            onPress={this.props.headerClicked}
            onLayout={(event) => {
              this.props.headerHeightUpdated(event.nativeEvent.layout.height);
            }}
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
    paddingBottom: 18,
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
    height: 147,
  },
});
