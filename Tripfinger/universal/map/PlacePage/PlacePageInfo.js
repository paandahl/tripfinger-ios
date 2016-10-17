import React from 'react';
import ReactNative from 'react-native';
import IconCell from './ListCells/IconCell';
import LinkCell from './ListCells/LinkCell';
import OpeningHoursCell from './ListCells/OpeningHours/OpeningHoursCell';
import InfoHeader from './InfoHeader';
import Utils from '../../shared/Utils';

const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;
const coordinatesIcon = require('../../../assets/placepage/coordinates.png');
const phoneIcon = require('../../../assets/placepage/number.png');
const websiteIcon = require('../../../assets/placepage/website.png');
const emailIcon = require('../../../assets/placepage/email.png');
const wifiIcon = require('../../../assets/placepage/wifi.png');

export default class PlacePageInfo extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    headerClicked: React.PropTypes.func.isRequired,
    headerHeightUpdated: React.PropTypes.func.isRequired,
    info: React.PropTypes.object,
    viewState: React.PropTypes.string.isRequired,
    panHandlers: React.PropTypes.any,
    location: React.PropTypes.object,
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
    const key = `${sectionId}:${rowId}`;
    if (rowId === 'gps') {
      const text = `${data.lat} ${data.lon}`;
      return <IconCell key={key} text={text} icon={coordinatesIcon} />;
    } else if (rowId === 'phoneNumber') {
      return <LinkCell key={key} text={data} icon={phoneIcon} url={`telprompt:${data}`} />;
    } else if (rowId === 'website') {
      return <LinkCell key={key} text={data} icon={websiteIcon} url={data} />;
    } else if (rowId === 'email') {
      return <LinkCell key={key} text={data} icon={emailIcon} url={`mailto:${data}`} />;
    } else if (rowId === 'openHours') {
      return <OpeningHoursCell openingHours={data} />;
    } else if (rowId === 'wifi') {
      return <IconCell key={key} text="Yes" icon={wifiIcon} />;
    }
    return null;
  };

  render() {
    if (this.props.info !== null) {
      this.featureView = (
        <View style={styles.info} {...this.props.panHandlers}>
          <InfoHeader
            info={this.props.info} onClick={this.props.headerClicked} location={this.props.location}
            onHeaderHeightUpdate={this.props.headerHeightUpdated} viewState={this.props.viewState}
          />
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
  featureDetails: {
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  featureList: {
    marginTop: 20,
    marginBottom: 20,
  },
  hiddenFooter: {
    height: 147, // 47pt actionbar + 100pt extra for when openinghours collapses
  },
});
