import React from 'react';
import ReactNative from 'react-native';
import IconCell from './list_cells/IconCell';
import LinkCell from './list_cells/LinkCell';
import OpeningHoursCell from './list_cells/opening_hours/OpeningHoursCell';
import Utils from '../Utils';

const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;
const coordinatesIcon = require('../../../assets/placepage/coordinates.png');
const phoneIcon = require('../../../assets/placepage/number.png');
const websiteIcon = require('../../../assets/placepage/website.png');
const emailIcon = require('../../../assets/placepage/email.png');
const wifiIcon = require('../../../assets/placepage/wifi.png');

export default class FeatureTable extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    listing: React.PropTypes.object.isRequired,
  };

  static fillDatasource(dataSource, listing) {
    const data = {};
    const rows = [];
    if (listing.phone) {
      data.phone = listing.phone;
      rows.push('phone');
    }
    if (listing.url) {
      data.url = listing.url;
      rows.push('url');
    }
    if (listing.email) {
      data.email = listing.email;
      rows.push('email');
    }
    if (listing.openingHours) {
      data.openingHours = listing.openingHours;
      rows.push('openingHours');
    }
    const lat = listing.latitude.toFixed(6);
    const lon = listing.longitude.toFixed(6);
    data.gps = { lat, lon };
    rows.push('gps');
    return {
      dataSource: dataSource.cloneWithRows(data, rows),
    };
  }

  constructor(props) {
    super(props);
    if (props.listing) {
      this.state = FeatureTable.fillDatasource(Utils.simpleDataSource(), props.listing);
    } else {
      this.state = {
        dataSource: Utils.simpleDataSource(),
      };
      this.featureView = <View />;
    }
  }

  componentWillReceiveProps(newProps) {
    if (newProps.listing) {
      const newState = FeatureTable.fillDatasource(this.state.dataSource, newProps.listing);
      this.setState(newState);
    }
  }

  renderRow = (data, sectionId, rowId) => {
    const key = `${sectionId}:${rowId}`;
    if (rowId === 'gps') {
      const text = `${data.lat} ${data.lon}`;
      return <IconCell key={key} text={text} icon={coordinatesIcon} />;
    } else if (rowId === 'phone') {
      return <LinkCell key={key} text={data} icon={phoneIcon} url={`telprompt:${data}`} />;
    } else if (rowId === 'url') {
      return <LinkCell key={key} text={data} icon={websiteIcon} url={data} />;
    } else if (rowId === 'email') {
      return <LinkCell key={key} text={data} icon={emailIcon} url={`mailto:${data}`} />;
    } else if (rowId === 'openingHours') {
      return <OpeningHoursCell openingHours={data} />;
    } else if (rowId === 'wifi') {
      return <IconCell key={key} text="Yes" icon={wifiIcon} />;
    }
    return null;
  };

  render() {
    if (this.props.listing !== null) {
      this.featureView = (
        <View style={styles.featureDetails}>
          <ListView
            automaticallyAdjustContentInsets={false}
            bounces={false}
            removeClippedSubviews={false}
            style={styles.featureList}
            dataSource={this.state.dataSource}
            renderRow={this.renderRow}
          />
        </View>
      );
    }
    return this.featureView;
  }
}

const styles = StyleSheet.create({
  featureDetails: {
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  featureList: {
    marginTop: 20,
    marginBottom: 20,
  },
});
